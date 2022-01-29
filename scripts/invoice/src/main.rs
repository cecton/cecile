fn main() -> anyhow::Result<()> {
    <Cli as clap::Parser>::parse().run()
}

macro_rules! generate_invoice_structs {
    ($( $field_name:ident: $field_ty:ty , )*) => {
        #[derive(serde::Serialize, serde::Deserialize)]
        pub struct Invoice {
            $(
                pub $field_name: $field_ty,
            )*
        }

        #[derive(clap::Parser)]
        pub struct InvoiceClap {
            $(
                #[clap(long)]
                pub $field_name: Option<$field_ty>,
            )*
        }

        impl Invoice {
            pub fn from_template_and_clap(template: Invoice, clap_struct: InvoiceClap) -> Self {
                Self {
                    $(
                        $field_name:
                        clap_struct.$field_name.unwrap_or(template.$field_name),
                    )*
                }
            }
        }
    };
}

generate_invoice_structs!(
    rate: f32,
    days: f32,
    invoice_year: u16,
    invoice_id: u16,
    vat: f32,
    company_name: String,
    company_address: Vec<String>,
    client_name: String,
    client_slug: String,
    client_address: Vec<String>,
    period: String,
    description: Vec<String>,
    date: String,
    location: String,
    bank: String,
    iban: String,
    bic: String,
    grace_period_days: u16,
);

#[derive(clap::Parser)]
pub struct Cli {
    #[clap(flatten)]
    invoice: InvoiceClap,

    #[clap(short = 'o', long, default_value = ".")]
    output: std::path::PathBuf,

    template: std::path::PathBuf,
}

impl Cli {
    pub fn run(self) -> anyhow::Result<()> {
        use std::io::Write;

        let template: Invoice = serde_yaml::from_reader(std::fs::File::open(self.template)?)?;
        let invoice = Invoice::from_template_and_clap(template, self.invoice);
        let generation_date = chrono::Local::now().format("%F");
        let file_name = format!("invoice-{}-{}", invoice.client_slug, generation_date);
        let file_path = self.output.join(&file_name);
        let yml_path = file_path.with_extension("yml");
        let svg_path = file_path.with_extension("svg");
        let pdf_path = file_path.with_extension("pdf");

        serde_yaml::to_writer(std::fs::File::create(&yml_path)?, &invoice)?;

        let price = invoice.rate * invoice.days;
        let price_vat = price * invoice.vat / 100.0;
        let total = price + price_vat;
        let mut source = vec![invoice.company_name.clone()];
        source.extend(invoice.company_address);
        let mut destination = vec![invoice.client_name];
        destination.extend(invoice.client_address);
        let date_and_location = format!("{}, {}", invoice.location, invoice.date);
        let mut file = std::fs::File::create(&svg_path)?;
        write!(
            file,
            include_str!("../invoice_template.svg"),
            price = price,
            vat = invoice.vat,
            price_vat = price_vat,
            total = total,
            source = source.join("\n"),
            destination = destination.join("\n"),
            date_and_location = date_and_location,
            invoice_year = invoice.invoice_year,
            invoice_id = invoice.invoice_id,
            period = invoice.period,
            description = invoice.description.join("\n"),
            days = invoice.days,
            rate = invoice.rate,
            grace_period_days = invoice.grace_period_days,
            company_name = invoice.company_name,
            bank = invoice.bank,
            iban = invoice.iban,
            bic = invoice.bic,
        )?;

        let mut command = std::process::Command::new("convert");
        command.args(["-units", "pixelsperinch", "-density", "300", "-page", "a4"]);
        command.arg(&svg_path);
        command.args(["-units", "pixelsperinch", "-density", "72", "-page", "a4"]);
        command.arg(&pdf_path);
        anyhow::ensure!(command.status()?.success(), "PDF generation failed");

        Ok(())
    }
}
