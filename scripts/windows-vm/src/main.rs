use anyhow::{bail, Context, Result};
use std::fs;
use std::io;
use std::io::prelude::*;
use std::os::unix::net::UnixStream;
use std::os::unix::process::CommandExt;
use std::process;
use std::time;
use structopt::StructOpt;

const NR_HUGEPAGES: &str = "/proc/sys/vm/nr_hugepages";
const HUGEPAGE_SIZE: u64 = 512;
const QEMU_COMMAND: &str = "qemu-system-x86_64";
#[rustfmt::skip]
const QEMU_ARGS: &[&str] = &[
    "-enable-kvm",
    "-overcommit", "mem-lock=off",
    "-machine", "pc-i440fx-2.9,accel=kvm,usb=off,vmport=off,dump-guest-core=off",
    "-msg", "timestamp=on",
    //"-cpu", "host,kvm=off,hv_vendor_id=null,hv-time,hv-relaxed,hv-vapic,hv-spinlocks=0x1fff,+topoext",
    //"-cpu", "host,kvm=off,hv_vendor_id=null",
    "-cpu", "host,+topoext",
    "-smp", "18,sockets=1,cores=9,threads=2",
    //"-smp", "1,sockets=1,cores=1,threads=1",
    "-mem-path", "/dev/hugepages",
    "-rtc", "base=utc,clock=host",
    "-device", "vfio-pci,host=0a:00.0,multifunction=on,x-vga=on",
    "-device", "vfio-pci,host=0a:00.1",
    // USB card
    "-device", "vfio-pci,host=05:00.0",
    //"-device", "vfio-pci,host=0f:00.3",
    "-drive", "file=/dev/nvme0n1,format=raw,discard=unmap",
    "-drive", "file=/dev/nvme1n1,format=raw,discard=unmap",
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
    "-usb", "-device", "usb-host,vendorid=0x0e8f,productid=0x3010,id=sat",        // Saturn gamepads
    //"-usb", "-device", "usb-host,vendorid=0x0483,productid=0xcdab",    // U2F
];
const MONITOR_SOCKET: &str = "/tmp/win.monitor";

#[derive(Debug, StructOpt)]
struct Cli {
    /// Memory (in GB)
    #[structopt(short = "m", default_value = "16")]
    memory: u64,
}

impl Cli {
    fn run(&self) -> Result<()> {
        let hugepages = self.memory * HUGEPAGE_SIZE;

        if nr_hugepages()? < hugepages {
            fs::write(NR_HUGEPAGES, "0").context("could not reset hugepages")?;
            fs::write(NR_HUGEPAGES, hugepages.to_string()).context("could not change hugepages")?;
            if nr_hugepages()? < hugepages {
                bail!("could not allocate huge pages");
            }
        }

        match unsafe { nix::unistd::fork() } {
            Ok(nix::unistd::ForkResult::Parent { .. }) => {
                ctrlc::set_handler(move || {
                    if let Ok(mut stream) = UnixStream::connect(MONITOR_SOCKET) {
                        let _ = stream.set_read_timeout(Some(time::Duration::from_secs(3)));
                        let _ = stream.set_write_timeout(Some(time::Duration::from_secs(3)));
                        let _ = writeln!(stream, "system_powerdown\n");
                        let _ = io::copy(&mut stream, &mut io::stdout());
                    }
                })
                .context("failed to set CTRL-C handler")?;

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
                Err(process::Command::new(QEMU_COMMAND)
                    .arg("-m")
                    .arg(format!("{}G", self.memory))
                    .args(&["-name", "windows,debug-threads=on"])
                    .arg("-monitor")
                    .arg(format!("unix:{},server,nowait", MONITOR_SOCKET))
                    .args(QEMU_ARGS)
                    .exec())
                .context("failed to run qemu")
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

fn main() -> Result<()> {
    Cli::from_args().run()
}
