use rusqlite::Connection;
use clap::Parser;
use regex::Regex;
use serde::Serialize;

#[derive(Debug, Serialize)]
struct Requirement {
    name: String,
    alias: Option<String>,
    note: String,
}

#[derive(Parser, Debug)]
struct Args {
    database: String,

    /// Requirement name filter (regex, case sensitive)
    #[arg(short, long, value_parser = parse_regex, default_value_t = Regex::new(".*").unwrap())]
    requirement: Regex,

    /// Output in JSON format
    #[arg(short, long, default_value_t = false)]
    json: bool,
}

fn parse_regex(s: &str) -> Result<Regex, String> {
    Regex::new(s)
        .map_err(|e| e.to_string())
}

fn main() {
    let args = Args::parse();

    let conn = Connection::open(args.database).expect("Failed to open database");

    let mut statement = conn
        .prepare("SELECT Name, Alias, Note FROM t_object WHERE Object_Type is 'Requirement'")
        .expect("Failed to prepare statement");
    let requirements = statement.query_map([], |row| {
        Ok(Requirement {
            name: row.get(0)?,
            alias: row.get(1)?,
            note: row.get(2)?,
        })
    }).unwrap()
    .filter_map(Result::ok)
    .filter(|req| args.requirement.is_match(&req.name))
    .collect::<Vec<Requirement>>();



    if args.json {
        let json = serde_json::to_string_pretty(&requirements).expect("Failed to serialize to JSON");
        println!("{}", json);
        return;
    }
    for requirement in requirements {
        println!("{} ({})\n{}",
            requirement.name,
            requirement.alias.as_deref().unwrap_or(""),
            requirement.note);
        println!("----------------------------------------\n");
    }
}
