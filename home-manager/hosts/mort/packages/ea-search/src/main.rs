use rusqlite::Connection;
use clap::Parser;
use regex::{Regex, RegexBuilder};
use serde::Serialize;
use std::io::{self, BufWriter, Write};

#[derive(Debug, Serialize)]
struct Requirement {
    name: String,
    alias: Option<String>,
    note: String,
    #[serde(rename = "Stereotype")]
    stereotype: Option<String>,
    #[serde(rename = "TruckModels")]
    truck_models: Option<String>,
    #[serde(rename = "Requirement:Stakeholder")]
    stakeholder: Option<String>,
}

#[derive(Parser, Debug)]
#[command(after_help = r#"Filters requirements from a SQLite (qea) database and outputs them in text or JSON format.
Filters are case-insensitive regex patterns. To make them case-sensitive, use the `(?-i)` flag in the regex pattern.
"#)]
struct Args {
    database: String,

    /// Requirement name filter (regex, case insensitive)
    #[arg(short, long, value_parser = parse_regex, default_value_t = Regex::new(".*").unwrap())]
    requirement: Regex,

    // Truck model filter (regex, case insensitive)
    #[arg(short, long, value_parser = parse_regex, default_value_t = Regex::new(".*").unwrap())]
    truck_model: Regex,

    /// Output in JSON format
    #[arg(short, long, default_value_t = false)]
    json: bool,
}

fn parse_regex(s: &str) -> Result<Regex, String> {
    RegexBuilder::new(s)
        .case_insensitive(true)
        .build()
        .map_err(|e| e.to_string())
}

fn main() {
    if let Err(error) = run() {
        if error.kind() != io::ErrorKind::BrokenPipe {
            eprintln!("Failed to write output: {error}");
            std::process::exit(1);
        }
    }
}

fn run() -> io::Result<()> {
    let args = Args::parse();

    let conn = Connection::open(args.database).expect("Failed to open database");

    let mut statement = conn
        .prepare(
            "SELECT o.Name, o.Alias, o.Note, o.Stereotype,
                    (SELECT p.Value
                     FROM t_objectproperties p
                     WHERE p.Object_ID = o.Object_ID AND p.Property = 'TruckModels'
                     LIMIT 1),
                    (SELECT p.Value
                     FROM t_objectproperties p
                     WHERE p.Object_ID = o.Object_ID AND p.Property = 'Requirement:Stakeholder'
                     LIMIT 1)
             FROM t_object o
             WHERE o.Object_Type IS 'Requirement'",
        )
        .expect("Failed to prepare statement");
    let requirements = statement.query_map([], |row| {
        Ok(Requirement {
            name: row.get(0)?,
            alias: row.get(1)?,
            note: row.get(2)?,
            stereotype: row.get(3)?,
            truck_models: row.get(4)?,
            stakeholder: row.get(5)?,
        })
    }).unwrap()
    .filter_map(Result::ok)
    .filter(|req| args.requirement.is_match(&req.name))
    .filter(|req| args.truck_model.is_match(req.truck_models.as_deref().unwrap_or("")))
    .collect::<Vec<Requirement>>();

    let stdout = io::stdout();
    let mut output = BufWriter::new(stdout.lock());

    if args.json {
        let json = serde_json::to_string_pretty(&requirements).expect("Failed to serialize to JSON");
        writeln!(output, "{json}")?;
        return output.flush();
    }
    for requirement in requirements {
        writeln!(
            output,
            "{} ({})\n{}",
            requirement.name,
            requirement.alias.as_deref().unwrap_or(""),
            requirement.note
        )?;
        if let Some(stereotype) = requirement.stereotype {
            writeln!(output, "Stereotype: {stereotype}")?;
        }
        if let Some(truck_models) = requirement.truck_models {
            writeln!(output, "TruckModels: {truck_models}")?;
        }
        if let Some(stakeholder) = requirement.stakeholder {
            writeln!(output, "Requirement:Stakeholder: {stakeholder}")?;
        }
        writeln!(output, "----------------------------------------\n")?;
    }
    output.flush()
}
