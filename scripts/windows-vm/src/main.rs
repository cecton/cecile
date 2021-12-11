use anyhow::{bail, ensure, Context, Result};
use libc::{cpu_set_t, sched_setaffinity, CPU_SET};
use once_cell::sync::Lazy;
use regex::Regex;
use simple_logger::SimpleLogger;
use std::collections::hash_map::{Entry, HashMap};
use std::fs;
use std::io;
use std::io::prelude::*;
use std::mem;
use std::os::unix::net::UnixStream;
use std::os::unix::process::CommandExt;
use std::path;
use std::process;
use std::thread;
use std::time;
use structopt::StructOpt;

const NR_HUGEPAGES: &str = "/proc/sys/vm/nr_hugepages";
const HUGEPAGE_SIZE: u64 = 512;
const QEMU_COMMAND: &str = "/usr/bin/qemu-system-x86_64";
#[rustfmt::skip]
const QEMU_ARGS_CPU_HOST: &[&str] = &[
    //"-cpu", "host,kvm=off,topoext=on,host-cache-info=on,hv_relaxed,hv_vapic,hv_time,hv_vpindex,hv_synic,hv_frequencies,hv_vendor_id=1234567890ab,hv_spinlocks=0x1fff",
    //"-cpu", "host,kvm=off,hv_vendor_id=null,hv-time,hv-relaxed,hv-vapic,hv-spinlocks=0x1fff,+topoext",
    //"-cpu", "host,kvm=off,hv_vendor_id=null",
    //"-cpu", "host,+topoext,host-cache-info=on",
    "-cpu", "host,+topoext,host-cache-info=on",
];
#[rustfmt::skip]
const QEMU_ARGS_CPU_QEMU: &[&str] = &[
    //"-cpu", "qemu64,+ssse3,+sse4.1,+sse4.2,+x2apic,+topoext", // fastest
    "-cpu", "qemu64,+ssse3,+sse4.1,sse4a,+sse4.2,+x2apic,+topoext,+kvm,+mmxext,+sse2,+aes,+avx,+avx2,+fma,+sha-ni", // fastest with most features
];
#[rustfmt::skip]
const QEMU_ARGS: &[&str] = &[
    "-enable-kvm",
    "-overcommit", "mem-lock=off",
    "-machine", "q35,accel=kvm,usb=off,vmport=off,dump-guest-core=off,mem-merge=off",
    "-msg", "timestamp=on",
    "-mem-prealloc", "-mem-path", "/dev/hugepages",
    "-rtc", "base=utc,clock=host",
    "-device", "vfio-pci,host=0a:00.0,multifunction=on,x-vga=on",
    "-device", "vfio-pci,host=0a:00.1",
    // USB card
    "-device", "vfio-pci,host=05:00.0",
    //"-device", "vfio-pci,host=0f:00.3",
    "-drive", "file=/dev/nvme0n1,format=raw,discard=unmap,id=NVME0",
    //"-device", "nvme,drive=NVME0,serial=nvme-0",
    "-drive", "file=/dev/nvme1n1,format=raw,discard=unmap,if=none,id=NVME1",
    "-device", "nvme,drive=NVME1,serial=nvme-1",
    "-drive", "file=/dev/sda,format=raw,discard=unmap",
    "-net", "nic,model=e1000,macaddr=52:54:00:12:34:56", "-net", "bridge,br=br0",
    "-vga", "none", "-display", "none",
    "--bios", "/usr/share/ovmf/x64/OVMF_CODE.fd", "-L", ".",
    // looking glass
    //"-usbdevice", "tablet",
    //"-device", "ivshmem-plain,memdev=ivshmem,bus=pci.0", "-object", "memory-backend-file,id=ivshmem,share=on,mem-path=/dev/shm/looking-glass,size=64M",
    //"-spice", "unix,addr=/tmp/win.sock,disable-ticketing,seamless-migration=on",
    "-device", "nec-usb-xhci,id=xhci,addr=0x7",
    "-usb", "-device", "usb-host,vendorid=0x046d,productid=0xc21d,id=f310",        // Logitech gamepad
    "-usb", "-device", "usb-host,vendorid=0x0433,productid=0x0004,id=fps1",        // FPS keyboard (old)
    "-usb", "-device", "usb-host,vendorid=0x0c45,productid=0x760a,id=fps2",        // FPS keyboard
    "-usb", "-device", "usb-host,vendorid=0x0e8f,productid=0x3010,id=sat",         // Saturn gamepads
    //"-usb", "-device", "usb-host,vendorid=0x2f24,productid=0x00ae,id=f500_blue",   // F500 blue
    //"-usb", "-device", "usb-host,vendorid=0x0483,productid=0xcdab",    // U2F
    "-serial", "pty",
];
const MONITOR_SOCKET: &str = "/tmp/win.monitor";
const CPU_DEVICES: &str = "/sys/bus/cpu/devices/";

#[derive(Debug, StructOpt)]
struct Cli {
    /// Memory (in GB)
    #[structopt(long, short = "m", default_value = "16")]
    memory: u64,
    /// Cores (half by default)
    #[structopt(long, short = "c")]
    cores: Option<usize>,
    /// Debug logs
    #[structopt(long, short = "d")]
    debug: bool,
    /// Disable hyperthread.
    #[structopt(long)]
    no_hyperthread: bool,
    /// Run with -cpu host
    #[structopt(long = "host")]
    cpu_host: bool,
}

impl Cli {
    fn run(&self) -> Result<()> {
        let mut logger = SimpleLogger::new();
        if !self.debug {
            logger = logger.with_level(log::LevelFilter::Info);
        }
        logger.init().unwrap();

        let mut threads = 1;
        let mut cores = (0..)
            .map(|i| {
                let cpu_path = path::PathBuf::from(CPU_DEVICES).join(format!("cpu{}", i));

                macro_rules! read_info {
                    ($path:expr) => {
                        match fs::read_to_string(cpu_path.join($path)) {
                            Ok(content) => u32::from_str_radix(content.trim(), 10)
                                .context("could not parse value of CPU info")?,
                            Err(err) if i == 0 => {
                                return Err(err).context("could not get CPU infos")
                            }
                            Err(_) => return Ok(None),
                        }
                    };
                }

                let core_id = read_info!("topology/core_id");
                let physical_package_id = read_info!("topology/physical_package_id");
                let index_3 = read_info!("cache/index3/id");

                Ok(Some((i, core_id, (physical_package_id, index_3))))
            })
            // TODO: replace by map_while when it becomes available
            //       https://doc.rust-lang.org/std/iter/trait.Iterator.html#method.map_while
            .map(|x| x.transpose())
            .take_while(|x| x.is_some())
            .flatten()
            .try_fold(HashMap::<u32, Core<_>>::new(), |mut acc, x| {
                x.and_then(|(i, core_id, topology_key)| {
                    match acc.entry(core_id) {
                        Entry::Occupied(mut entry) => {
                            if !self.no_hyperthread {
                                let core = entry.get_mut();
                                if core.hyperthread_id.is_some() {
                                    bail!("more than 2 CPUs detected for a single core");
                                }
                                core.hyperthread_id = Some(i);
                                threads = 2;
                            }
                        }
                        Entry::Vacant(entry) => {
                            entry.insert(Core {
                                core_id,
                                cpu_id: i,
                                topology_key,
                                hyperthread_id: None,
                            });
                        }
                    }
                    Ok(acc)
                })
            })?
            // TODO: replace by into_values when it becomes available
            //       https://doc.rust-lang.org/std/collections/struct.HashMap.html#method.into_values
            .values()
            .cloned()
            .collect::<Vec<_>>();

        cores.sort_unstable_by(|a, b| {
            b.topology_key
                .cmp(&a.topology_key)
                .then(a.cpu_id.cmp(&b.cpu_id))
        });

        for core in cores.iter() {
            log::debug!(
                "core={:02} cpu={:02} hyperthread={:02?} sort={:?}",
                core.core_id,
                core.cpu_id,
                core.hyperthread_id,
                core.topology_key,
            );
        }

        log::debug!("Threads detected: {}", threads);

        let num_cores = self.cores.unwrap_or_else(|| cores.len() / 2);
        let mut it = cores.into_iter();
        let cores = (0..num_cores).flat_map(|_| it.next()).collect::<Vec<_>>();
        let other_cores = it.collect::<Vec<_>>();
        let mut numa_nodes = cores
            .iter()
            .enumerate()
            .fold(HashMap::<_, Vec<_>>::new(), |mut acc, (cpu_id, core)| {
                let vec = acc.entry(core.topology_key).or_default();
                for thread_id in 0..threads {
                    vec.push((cpu_id, thread_id));
                }
                acc
            })
            .into_iter()
            .map(|(_, vcpus)| vcpus)
            .collect::<Vec<_>>();
        numa_nodes.sort_unstable_by(|a, b| a.cmp(&b));

        ensure!(
            self.memory % numa_nodes.len() as u64 == 0,
            "memory size must be a multiple of {}",
            numa_nodes.len()
        );

        let memory_per_numa = self.memory / numa_nodes.len() as u64;

        if other_cores.is_empty() {
            bail!("Not enough core left to start the VM");
        }

        for vcpus in numa_nodes.iter() {
            log::debug!("NUMA node: memory={}G vcpus={:?}", memory_per_numa, vcpus);
        }

        log::debug!(
            "Cores for the virtual CPUs: {:?}",
            cores.iter().map(|x| x.core_id).collect::<Vec<_>>()
        );
        log::debug!(
            "Cores for the other tasks: {:?}",
            other_cores.iter().map(|x| x.core_id).collect::<Vec<_>>()
        );

        let interleave_cpus = match cores[0] {
            Core {
                cpu_id,
                hyperthread_id: Some(hyperthread_id),
                ..
            } => hyperthread_id == cpu_id + 1,
            _ => false,
        };

        log::debug!("Interleave CPUs: {}", interleave_cpus);

        let cpus = if interleave_cpus {
            cores
                .iter()
                .flat_map(|core| vec![Some(core.cpu_id), core.hyperthread_id])
                .flatten()
                .collect::<Vec<_>>()
        } else {
            cores
                .iter()
                .map(|core| core.cpu_id)
                .chain(cores.iter().filter_map(|core| core.hyperthread_id))
                .collect::<Vec<_>>()
        };

        log::debug!("CPUs: {:?}", &cpus);

        let hugepages = self.memory * HUGEPAGE_SIZE;

        log::debug!("Hugepages: {}", hugepages);

        if nr_hugepages()? < hugepages {
            fs::write(NR_HUGEPAGES, "0").context("could not reset hugepages")?;
            fs::write(NR_HUGEPAGES, hugepages.to_string()).context("could not change hugepages")?;
            if nr_hugepages()? < hugepages {
                bail!("could not allocate huge pages");
            }
        }

        match unsafe { nix::unistd::fork() } {
            Ok(nix::unistd::ForkResult::Parent { child }) => {
                ctrlc::set_handler(move || {
                    if let Ok(mut stream) = UnixStream::connect(MONITOR_SOCKET) {
                        let _ = stream.set_read_timeout(Some(time::Duration::from_secs(3)));
                        let _ = stream.set_write_timeout(Some(time::Duration::from_secs(3)));
                        let _ = writeln!(stream, "system_powerdown\n");
                        let _ = io::copy(&mut stream, &mut io::stdout());
                        thread::sleep(time::Duration::from_secs(1));
                    }
                })
                .context("failed to set CTRL-C handler")?;

                let (mut cpu_tasks, other_tasks) = loop {
                    thread::sleep(time::Duration::from_secs(1));

                    let tasks = fs::read_dir(format!("/proc/{}/task", child))
                        .context("could not read task info directory")?
                        .map(|entry| entry.context("could not read task info directory entry"))
                        .collect::<Result<Vec<_>>>()?
                        .into_iter()
                        .map(|entry| {
                            Ok((
                                i32::from_str_radix(entry.file_name().to_str().unwrap(), 10)
                                    .unwrap(),
                                TaskType::from_str(
                                    &fs::read_to_string(entry.path().join("comm"))
                                        .context("could not read task info")?,
                                ),
                            ))
                        })
                        .collect::<Result<Vec<_>>>()?;

                    let cpu_tasks = tasks
                        .iter()
                        .filter_map(|(task_id, task_type)| match task_type {
                            TaskType::Cpu(cpu_id) => Some((*task_id, *cpu_id)),
                            _ => None,
                        })
                        .collect::<Vec<(i32, usize)>>();

                    if !cpu_tasks.is_empty() {
                        log::debug!("QEMU tasks: {:?}", &tasks);

                        let other_tasks = tasks
                            .into_iter()
                            .filter_map(|(task_id, task_type)| match task_type {
                                TaskType::Cpu(_) => None,
                                _ => Some((task_id, task_type)),
                            })
                            .collect::<Vec<(i32, TaskType)>>();

                        break (cpu_tasks, other_tasks);
                    }
                };

                cpu_tasks.sort_unstable_by_key(|(_task_id, cpu_id)| *cpu_id);

                log::debug!("QEMU CPU tasks: {:?}", &cpu_tasks);

                for (cpu_id, (task_id, vm_cpu_id)) in cpus.iter().zip(cpu_tasks) {
                    log::debug!(
                        "Assigning VM CPU {vm_cpu_id} (task {task_id}) to CPU {cpu_id}",
                        cpu_id = cpu_id,
                        task_id = task_id,
                        vm_cpu_id = vm_cpu_id,
                    );

                    let mut set = unsafe { mem::zeroed::<cpu_set_t>() };

                    unsafe { CPU_SET(*cpu_id, &mut set) };

                    unsafe {
                        sched_setaffinity(task_id, mem::size_of::<cpu_set_t>(), &set);
                    }
                }

                let other_cpus = other_cores
                    .iter()
                    .map(|core| core.cpu_id)
                    .chain(other_cores.iter().flat_map(|core| core.hyperthread_id))
                    .collect::<Vec<_>>();

                let mut other_cpus_set = unsafe { mem::zeroed::<cpu_set_t>() };
                for cpu_id in other_cpus.iter() {
                    unsafe { CPU_SET(*cpu_id, &mut other_cpus_set) };
                }

                for (task_id, task_type) in other_tasks {
                    log::debug!(
                        "Assigning task {task_id} ({task_type:?}) to CPUs: {other_cpus:?}",
                        task_id = task_id,
                        task_type = task_type,
                        other_cpus = other_cpus,
                    );

                    unsafe {
                        sched_setaffinity(task_id, mem::size_of::<cpu_set_t>(), &other_cpus_set);
                    }
                }

                match nix::sys::wait::wait() {
                    Ok(nix::sys::wait::WaitStatus::Exited(_, code)) if code != 0 => {
                        bail!("command exited with status: {}", code);
                    }
                    Ok(nix::sys::wait::WaitStatus::Signaled(_, signal, _)) => {
                        bail!("command has been stopped by signal: {}", signal);
                    }
                    _ => Ok(()),
                }
            }
            Ok(nix::unistd::ForkResult::Child) => {
                nix::unistd::setsid().context("could not create new session")?;

                let mut command = process::Command::new(QEMU_COMMAND);
                command
                    .args(&["-name", "windows,debug-threads=on"])
                    .arg("-monitor")
                    .arg(format!("unix:{},server,nowait", MONITOR_SOCKET))
                    .arg("-m")
                    .arg(format!("{}G", self.memory));

                if self.cpu_host {
                    command.args(QEMU_ARGS_CPU_HOST);
                } else {
                    command.args(QEMU_ARGS_CPU_QEMU);
                    for (i, _vcpus) in numa_nodes.iter().enumerate() {
                        command.arg("-object");
                        command.arg(format!(
                            "memory-backend-ram,size={}G,id=m{}",
                            memory_per_numa, i
                        ));
                        command.arg("-numa");
                        command.arg(&format!("node,nodeid={},memdev=m{}", i, i));
                    }

                    for (i, vcpus) in numa_nodes.iter().enumerate() {
                        for (core_id, thread_id) in vcpus {
                            command.arg("-numa");
                            command.arg(&format!(
                                "cpu,node-id={},socket-id=0,core-id={},thread-id={}",
                                i, core_id, thread_id
                            ));
                        }
                    }
                }

                command.arg("-smp").arg(format!(
                    "{},sockets=1,cores={},threads={}",
                    num_cores * threads,
                    num_cores,
                    threads,
                ));

                Err(command.args(QEMU_ARGS).exec()).context("failed to run qemu")
            }
            Err(err) => Err(err).context("failed to fork"),
        }
    }
}

impl Drop for Cli {
    fn drop(&mut self) {
        let _ = fs::write(NR_HUGEPAGES, "0");
    }
}

fn nr_hugepages() -> Result<u64> {
    Ok(u64::from_str_radix(
        fs::read_to_string(NR_HUGEPAGES)
            .with_context(|| format!("could not read hugepages: {}", NR_HUGEPAGES))?
            .trim(),
        10,
    )
    .expect("could not parse hugepages as integer"))
}

#[derive(Debug, Clone, Copy)]
struct Core<S: PartialOrd> {
    cpu_id: usize,
    core_id: u32,
    topology_key: S,
    hyperthread_id: Option<usize>,
}

#[derive(Debug, Clone)]
enum TaskType {
    Emulator,
    Cpu(usize),
    Worker,
    Other(String),
}

impl TaskType {
    fn from_str(s: &str) -> Self {
        static RE_EMULATOR: Lazy<Regex> = Lazy::new(|| Regex::new(r"^qemu-system-").unwrap());
        static RE_CPU: Lazy<Regex> = Lazy::new(|| Regex::new(r"^CPU (\d+)").unwrap());
        static RE_WORKER: Lazy<Regex> = Lazy::new(|| Regex::new(r"^worker").unwrap());

        if RE_EMULATOR.is_match(s) {
            Self::Emulator
        } else if let Some(caps) = RE_CPU.captures(s) {
            Self::Cpu(usize::from_str_radix(&caps[1], 10).unwrap())
        } else if RE_WORKER.is_match(s) {
            Self::Worker
        } else {
            Self::Other(s.to_string())
        }
    }
}

fn main() -> Result<()> {
    Cli::from_args().run()
}
