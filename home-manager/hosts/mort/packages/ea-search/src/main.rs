use clap::{Parser, ValueEnum};
use ego_tree::NodeRef;
use regex::{Regex, RegexBuilder};
use rusqlite::Connection;
use scraper::{Html, Node};
use serde::Serialize;
use std::collections::{HashMap, HashSet};
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
    linked_requirements: Vec<Requirement>,
    #[serde(skip)]
    guid: Option<String>,
    #[serde(skip)]
    raw_note: String,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq, ValueEnum)]
enum OutputFormat {
    Text,
    Json,
    Markdown,
}

#[derive(Debug)]
struct RequirementRecord {
    guid: Option<String>,
    name: String,
    alias: Option<String>,
    note: String,
    raw_note: String,
    link_guids: Vec<String>,
    stereotype: Option<String>,
    truck_models: Option<String>,
    stakeholder: Option<String>,
}

struct ParsedNote {
    text: String,
    link_guids: Vec<String>,
}

#[derive(Default)]
struct ListContext {
    ordered: bool,
    next_number: usize,
}

#[derive(Parser, Debug)]
#[command(
    after_help = r#"Filters requirements from a SQLite (qea) database and outputs them in text, JSON, or Markdown format.
Filters are case-insensitive regex patterns. To make them case-sensitive, use the `(?-i)` flag in the regex pattern.
By default, only matched requirements are shown. Use --max-depth to include linked requirements.
"#
)]
struct Args {
    database: String,

    /// Requirement name filter (regex, case insensitive)
    #[arg(short, long, value_parser = parse_regex, default_value_t = Regex::new(".*").unwrap())]
    requirement: Regex,

    // Truck model filter (regex, case insensitive)
    #[arg(short, long, value_parser = parse_regex, default_value_t = Regex::new(".*").unwrap())]
    truck_model: Regex,

    /// Maximum depth of linked requirements (0 shows only matched requirements)
    #[arg(long, default_value_t = 0)]
    max_depth: usize,

    /// Output format
    #[arg(long, value_enum, default_value = "text")]
    format: OutputFormat,
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
            "SELECT o.ea_guid, o.Name, o.Alias, o.Note, o.Stereotype,
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
    let rows = statement
        .query_map([], |row| {
            Ok((
                row.get::<_, Option<String>>(0)?,
                row.get::<_, String>(1)?,
                row.get::<_, Option<String>>(2)?,
                row.get::<_, Option<String>>(3)?,
                row.get::<_, Option<String>>(4)?,
                row.get::<_, Option<String>>(5)?,
                row.get::<_, Option<String>>(6)?,
            ))
        })
        .expect("Failed to query requirements")
        .collect::<rusqlite::Result<Vec<_>>>()
        .expect("Failed to read requirements");

    let records = rows
        .into_iter()
        .map(
            |(guid, name, alias, raw_note, stereotype, truck_models, stakeholder)| {
                let raw_note = raw_note.unwrap_or_default();
                let ParsedNote { text, link_guids } = parse_note(&raw_note);
                RequirementRecord {
                    guid,
                    name,
                    alias,
                    note: text,
                    raw_note,
                    link_guids,
                    stereotype,
                    truck_models,
                    stakeholder,
                }
            },
        )
        .collect::<Vec<_>>();
    let guid_to_index = records
        .iter()
        .enumerate()
        .filter_map(|(index, record)| {
            record
                .guid
                .as_deref()
                .map(|guid| (normalize_guid(guid), index))
        })
        .collect::<HashMap<_, _>>();

    let requirements = records
        .iter()
        .enumerate()
        .filter(|(_, req)| args.requirement.is_match(&req.name))
        .filter(|(_, req)| {
            args.truck_model
                .is_match(req.truck_models.as_deref().unwrap_or(""))
        })
        .map(|(index, _)| {
            build_requirement(
                index,
                0,
                args.max_depth,
                &records,
                &guid_to_index,
                &mut HashSet::new(),
            )
        })
        .collect::<Vec<_>>();

    let stdout = io::stdout();
    let mut output = BufWriter::new(stdout.lock());

    match args.format {
        OutputFormat::Json => {
            let json =
                serde_json::to_string_pretty(&requirements).expect("Failed to serialize to JSON");
            writeln!(output, "{json}")?;
        }
        OutputFormat::Text => {
            for requirement in requirements {
                write_requirement_text(&mut output, &requirement, 0)?;
                writeln!(output, "----------------------------------------\n")?;
            }
        }
        OutputFormat::Markdown => write_requirements_markdown(&mut output, &requirements)?,
    }
    output.flush()
}

fn build_requirement(
    index: usize,
    depth: usize,
    max_depth: usize,
    records: &[RequirementRecord],
    guid_to_index: &HashMap<String, usize>,
    ancestry: &mut HashSet<String>,
) -> Requirement {
    let record = &records[index];
    let guid = record.guid.as_deref().map(normalize_guid);
    if let Some(guid) = guid.as_ref() {
        ancestry.insert(guid.clone());
    }

    let linked_requirements = if depth < max_depth {
        record
            .link_guids
            .iter()
            .filter_map(|linked_guid| guid_to_index.get(linked_guid).copied())
            .map(|linked_index| {
                let linked_guid = records[linked_index].guid.as_deref().map(normalize_guid);
                if linked_guid
                    .as_ref()
                    .is_some_and(|linked_guid| ancestry.contains(linked_guid))
                {
                    requirement_without_links(&records[linked_index])
                } else {
                    build_requirement(
                        linked_index,
                        depth + 1,
                        max_depth,
                        records,
                        guid_to_index,
                        ancestry,
                    )
                }
            })
            .collect()
    } else {
        Vec::new()
    };

    if let Some(guid) = guid {
        ancestry.remove(&guid);
    }

    Requirement {
        name: record.name.clone(),
        alias: record.alias.clone(),
        note: record.note.clone(),
        stereotype: record.stereotype.clone(),
        truck_models: record.truck_models.clone(),
        stakeholder: record.stakeholder.clone(),
        linked_requirements,
        guid: record.guid.clone(),
        raw_note: record.raw_note.clone(),
    }
}

fn requirement_without_links(record: &RequirementRecord) -> Requirement {
    Requirement {
        name: record.name.clone(),
        alias: record.alias.clone(),
        note: record.note.clone(),
        stereotype: record.stereotype.clone(),
        truck_models: record.truck_models.clone(),
        stakeholder: record.stakeholder.clone(),
        linked_requirements: Vec::new(),
        guid: record.guid.clone(),
        raw_note: record.raw_note.clone(),
    }
}

fn normalize_guid(guid: &str) -> String {
    guid.trim()
        .trim_start_matches('{')
        .trim_end_matches('}')
        .to_ascii_lowercase()
}

fn parse_element_guid(href: &str) -> Option<String> {
    let (scheme, value) = href.split_once("://")?;
    if !scheme.eq_ignore_ascii_case("$element") {
        return None;
    }
    let guid = value.strip_prefix('{')?.strip_suffix('}')?;
    if guid.len() != 36
        || !guid.bytes().enumerate().all(|(index, byte)| {
            if matches!(index, 8 | 13 | 18 | 23) {
                byte == b'-'
            } else {
                byte.is_ascii_hexdigit()
            }
        })
    {
        return None;
    }
    Some(guid.to_ascii_lowercase())
}

fn parse_note(html: &str) -> ParsedNote {
    let fragment = Html::parse_fragment(html);
    let mut output = String::new();
    let mut link_guids = Vec::new();
    let mut lists = Vec::new();
    for child in fragment.tree.root().children() {
        render_note_node(child, &mut output, &mut link_guids, &mut lists);
    }
    ParsedNote {
        text: normalize_note_text(&output),
        link_guids,
    }
}

fn render_note_node(
    node: NodeRef<'_, Node>,
    output: &mut String,
    link_guids: &mut Vec<String>,
    lists: &mut Vec<ListContext>,
) {
    match node.value() {
        Node::Text(text) => append_note_text(output, text.text.as_ref()),
        Node::Element(element) => {
            let name = element.name();
            if name.eq_ignore_ascii_case("a") {
                if let Some(href) = element.attr("href") {
                    if let Some(guid) = parse_element_guid(href) {
                        link_guids.push(guid);
                    }
                }
            }

            match name.to_ascii_lowercase().as_str() {
                "br" => ensure_newline(output),
                "p" | "div" => {
                    ensure_blank_line(output);
                    for child in node.children() {
                        render_note_node(child, output, link_guids, lists);
                    }
                    ensure_blank_line(output);
                }
                "ol" | "ul" => {
                    ensure_newline(output);
                    lists.push(ListContext {
                        ordered: name.eq_ignore_ascii_case("ol"),
                        next_number: 1,
                    });
                    for child in node.children() {
                        render_note_node(child, output, link_guids, lists);
                    }
                    lists.pop();
                    ensure_newline(output);
                }
                "li" => {
                    ensure_newline(output);
                    output.push_str(&"  ".repeat(lists.len().saturating_sub(1)));
                    if let Some(list) = lists.last_mut() {
                        if list.ordered {
                            output.push_str(&format!("{}. ", list.next_number));
                            list.next_number += 1;
                        } else {
                            output.push_str("- ");
                        }
                    } else {
                        output.push_str("- ");
                    }
                    for child in node.children() {
                        render_note_node(child, output, link_guids, lists);
                    }
                    ensure_newline(output);
                }
                _ => {
                    for child in node.children() {
                        render_note_node(child, output, link_guids, lists);
                    }
                }
            }
        }
        _ => {}
    }
}

fn append_note_text(output: &mut String, text: &str) {
    for character in text.chars() {
        match character {
            '\r' => {}
            '\n' => ensure_newline(output),
            value if value.is_whitespace() => {
                if !output.is_empty() && !output.ends_with([' ', '\n']) {
                    output.push(' ');
                }
            }
            value => output.push(value),
        }
    }
}

fn ensure_newline(output: &mut String) {
    while output.ends_with(' ') {
        output.pop();
    }
    if !output.is_empty() && !output.ends_with('\n') {
        output.push('\n');
    }
}

fn ensure_blank_line(output: &mut String) {
    ensure_newline(output);
    if !output.is_empty() && !output.ends_with("\n\n") {
        output.push('\n');
    }
}

fn normalize_note_text(text: &str) -> String {
    let mut lines = Vec::new();
    let mut has_blank_line = false;
    for line in text.split('\n') {
        let content = line.trim();
        if content.is_empty() {
            if !lines.is_empty() {
                has_blank_line = true;
            }
            continue;
        }
        if has_blank_line {
            lines.push(String::new());
            has_blank_line = false;
        }
        let indentation = line.len() - line.trim_start().len();
        let content = content.split_whitespace().collect::<Vec<_>>().join(" ");
        lines.push(format!("{}{}", " ".repeat(indentation), content));
    }
    lines.join("\n")
}

fn write_requirement_text(
    output: &mut impl Write,
    requirement: &Requirement,
    depth: usize,
) -> io::Result<()> {
    let indentation = "  ".repeat(depth);
    let prefix = if depth == 0 { "" } else { "- " };
    writeln!(
        output,
        "{indentation}{prefix}{} ({})",
        requirement.name,
        requirement.alias.as_deref().unwrap_or("")
    )?;
    for line in requirement.note.lines() {
        writeln!(output, "{indentation}  {line}")?;
    }
    if let Some(stereotype) = &requirement.stereotype {
        writeln!(output, "{indentation}  Stereotype: {stereotype}")?;
    }
    if let Some(truck_models) = &requirement.truck_models {
        writeln!(output, "{indentation}  TruckModels: {truck_models}")?;
    }
    if let Some(stakeholder) = &requirement.stakeholder {
        writeln!(
            output,
            "{indentation}  Requirement:Stakeholder: {stakeholder}"
        )?;
    }
    if !requirement.linked_requirements.is_empty() {
        writeln!(output, "{indentation}  Linked requirements:")?;
        for linked in &requirement.linked_requirements {
            write_requirement_text(output, linked, depth + 2)?;
        }
    }
    Ok(())
}

fn write_requirements_markdown(
    output: &mut impl Write,
    requirements: &[Requirement],
) -> io::Result<()> {
    let mut slug_counts = HashMap::new();
    let mut target_slugs = HashMap::new();
    for requirement in requirements {
        collect_heading_slugs(requirement, &mut slug_counts, &mut target_slugs);
    }

    for (index, requirement) in requirements.iter().enumerate() {
        if index > 0 {
            writeln!(output, "\n---\n")?;
        }
        write_requirement_markdown(output, requirement, 0, &target_slugs)?;
    }
    Ok(())
}

fn collect_heading_slugs(
    requirement: &Requirement,
    slug_counts: &mut HashMap<String, usize>,
    target_slugs: &mut HashMap<String, String>,
) {
    let base_slug = github_heading_slug(&requirement_heading(requirement));
    let count = slug_counts.entry(base_slug.clone()).or_insert(0);
    let slug = if *count == 0 {
        base_slug
    } else {
        format!("{base_slug}-{count}")
    };
    *count += 1;

    if let Some(guid) = requirement.guid.as_deref() {
        target_slugs.entry(normalize_guid(guid)).or_insert(slug);
    }
    for linked in &requirement.linked_requirements {
        collect_heading_slugs(linked, slug_counts, target_slugs);
    }
}

fn requirement_heading(requirement: &Requirement) -> String {
    match requirement.alias.as_deref() {
        Some(alias) if !alias.is_empty() => format!("{} ({alias})", requirement.name),
        _ => requirement.name.clone(),
    }
}

fn github_heading_slug(heading: &str) -> String {
    let mut slug = String::new();
    let mut pending_space = false;
    for character in heading.chars().flat_map(char::to_lowercase) {
        if character.is_alphanumeric() || matches!(character, '-' | '_') {
            if pending_space && !slug.is_empty() && !slug.ends_with('-') {
                slug.push('-');
            }
            pending_space = false;
            slug.push(character);
        } else if character.is_whitespace() {
            pending_space = true;
        }
    }
    if slug.is_empty() {
        "requirement".to_string()
    } else {
        slug
    }
}

fn write_requirement_markdown(
    output: &mut impl Write,
    requirement: &Requirement,
    depth: usize,
    target_slugs: &HashMap<String, String>,
) -> io::Result<()> {
    let heading_level = 1 + depth.min(5);
    let quote_prefix = "> ".repeat(depth.saturating_sub(5));
    writeln!(
        output,
        "{quote_prefix}{} {}",
        "#".repeat(heading_level),
        escape_markdown_text(&requirement_heading(requirement))
    )?;

    let note = render_markdown_note(&requirement.raw_note, target_slugs);
    if !note.is_empty() {
        writeln!(output)?;
        for line in note.lines() {
            writeln!(output, "{quote_prefix}{line}")?;
        }
    }

    let metadata = [
        requirement
            .stereotype
            .as_deref()
            .map(|value| ("Stereotype", value)),
        requirement
            .truck_models
            .as_deref()
            .map(|value| ("TruckModels", value)),
        requirement
            .stakeholder
            .as_deref()
            .map(|value| ("Requirement:Stakeholder", value)),
    ];
    let metadata = metadata.into_iter().flatten().collect::<Vec<_>>();
    if !metadata.is_empty() {
        writeln!(output)?;
        for (name, value) in metadata {
            writeln!(
                output,
                "{quote_prefix}- **{}:** {}",
                escape_markdown_text(name),
                escape_markdown_text(value)
            )?;
        }
    }

    if !requirement.linked_requirements.is_empty() {
        writeln!(output, "\n{quote_prefix}**Linked requirements**\n")?;
        for linked in &requirement.linked_requirements {
            write_requirement_markdown(output, linked, depth + 1, target_slugs)?;
        }
    }
    Ok(())
}

fn render_markdown_note(html: &str, target_slugs: &HashMap<String, String>) -> String {
    let fragment = Html::parse_fragment(html);
    let mut output = String::new();
    let mut lists = Vec::new();
    for child in fragment.tree.root().children() {
        render_markdown_node(child, &mut output, &mut lists, target_slugs);
    }
    normalize_note_text(&output)
}

fn render_markdown_node(
    node: NodeRef<'_, Node>,
    output: &mut String,
    lists: &mut Vec<ListContext>,
    target_slugs: &HashMap<String, String>,
) {
    match node.value() {
        Node::Text(text) => append_markdown_text(output, text.text.as_ref()),
        Node::Element(element) => {
            let name = element.name().to_ascii_lowercase();
            let target_slug = if name == "a" {
                element
                    .attr("href")
                    .and_then(parse_element_guid)
                    .and_then(|guid| target_slugs.get(&guid))
            } else {
                None
            };
            if target_slug.is_some() {
                output.push('[');
            }
            match name.as_str() {
                "b" | "strong" => output.push_str("**"),
                "i" | "em" => output.push('*'),
                _ => {}
            }
            match name.as_str() {
                "br" => ensure_newline(output),
                "p" | "div" => {
                    ensure_blank_line(output);
                    for child in node.children() {
                        render_markdown_node(child, output, lists, target_slugs);
                    }
                    ensure_blank_line(output);
                }
                "ol" | "ul" => {
                    ensure_newline(output);
                    lists.push(ListContext {
                        ordered: name == "ol",
                        next_number: 1,
                    });
                    for child in node.children() {
                        render_markdown_node(child, output, lists, target_slugs);
                    }
                    lists.pop();
                    ensure_newline(output);
                }
                "li" => {
                    ensure_newline(output);
                    output.push_str(&"  ".repeat(lists.len().saturating_sub(1)));
                    if let Some(list) = lists.last_mut() {
                        if list.ordered {
                            output.push_str(&format!("{}. ", list.next_number));
                            list.next_number += 1;
                        } else {
                            output.push_str("- ");
                        }
                    } else {
                        output.push_str("- ");
                    }
                    for child in node.children() {
                        render_markdown_node(child, output, lists, target_slugs);
                    }
                    ensure_newline(output);
                }
                _ => {
                    for child in node.children() {
                        render_markdown_node(child, output, lists, target_slugs);
                    }
                }
            }
            match name.as_str() {
                "b" | "strong" => output.push_str("**"),
                "i" | "em" => output.push('*'),
                _ => {}
            }
            if let Some(slug) = target_slug {
                output.push_str("](#");
                output.push_str(slug);
                output.push(')');
            }
        }
        _ => {}
    }
}

fn append_markdown_text(output: &mut String, text: &str) {
    for character in text.chars() {
        match character {
            '\r' => {}
            '\n' => ensure_newline(output),
            value if value.is_whitespace() => {
                if !output.is_empty() && !output.ends_with([' ', '\n']) {
                    output.push(' ');
                }
            }
            '\\' | '`' | '*' | '_' | '{' | '}' | '[' | ']' | '#' | '!' | '>' | '|' | '~' => {
                output.push('\\');
                output.push(character);
            }
            value => output.push(value),
        }
    }
}

fn escape_markdown_text(text: &str) -> String {
    let mut output = String::with_capacity(text.len());
    for character in text.chars() {
        if matches!(
            character,
            '\\' | '`' | '*' | '_' | '{' | '}' | '[' | ']' | '#' | '!' | '>' | '|' | '~'
        ) {
            output.push('\\');
        }
        output.push(character);
    }
    output
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn max_depth_defaults_to_zero() {
        let args = Args::try_parse_from(["ea-search", "database"]).unwrap();

        assert_eq!(args.max_depth, 0);
        assert_eq!(args.format, OutputFormat::Text);
    }

    #[test]
    fn format_option_accepts_text_json_and_markdown_only() {
        for (value, expected) in [
            ("text", OutputFormat::Text),
            ("json", OutputFormat::Json),
            ("markdown", OutputFormat::Markdown),
        ] {
            let args = Args::try_parse_from(["ea-search", "database", "--format", value]).unwrap();
            assert_eq!(args.format, expected);
        }
        assert!(Args::try_parse_from(["ea-search", "database", "--json"]).is_err());
    }

    #[test]
    fn parses_note_markup_and_extracts_ordered_element_links() {
        let parsed = parse_note(
            r#"<p><b>Need</b> <a href="$element://{9BE55DB6-C744-4505-9BC5-03904DF3E9FF}"><u>MOD-VCM-LHS-162</u></a> &gt; value</p><ol><li>first</li><li>second</li></ol><a href="https://example.com">external</a>"#,
        );

        assert_eq!(
            parsed.text,
            "Need MOD-VCM-LHS-162 > value\n\n1. first\n2. second\nexternal"
        );
        assert_eq!(parsed.link_guids, ["9be55db6-c744-4505-9bc5-03904df3e9ff"]);
    }

    #[test]
    fn markdown_notes_preserve_emphasis_lists_and_included_links() {
        let target_guid = "9be55db6-c744-4505-9bc5-03904df3e9ff";
        let target_slugs = HashMap::from([(target_guid.to_string(), "target-heading".to_string())]);
        let markdown = render_markdown_note(
            r#"<p><b>Need</b> <a href="$element://{9BE55DB6-C744-4505-9BC5-03904DF3E9FF}"><u>MOD-VCM-LHS-162</u></a> &gt; value</p><ul><li><i>first</i></li><li>second</li></ul>"#,
            &target_slugs,
        );

        assert_eq!(
            markdown,
            "**Need** [MOD-VCM-LHS-162](#target-heading) \\> value\n\n- *first*\n- second"
        );
    }

    #[test]
    fn markdown_links_fall_back_to_labels_when_target_is_absent() {
        let root = output_requirement(
            "{aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa}",
            "Root",
            "ROOT",
            r#"<a href="$element://{bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb}">Missing target</a>"#,
            Vec::new(),
        );
        let mut output = Vec::new();

        write_requirements_markdown(&mut output, &[root]).unwrap();
        let markdown = String::from_utf8(output).unwrap();

        assert!(markdown.contains("Missing target"));
        assert!(!markdown.contains("](#"));
    }

    #[test]
    fn markdown_links_point_to_included_requirement_headings() {
        let child = output_requirement(
            "{bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb}",
            "Child",
            "CHILD-1",
            "",
            Vec::new(),
        );
        let root = output_requirement(
            "{aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa}",
            "Root",
            "ROOT",
            r#"<a href="$element://{bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb}">Child requirement</a>"#,
            vec![child],
        );
        let mut output = Vec::new();

        write_requirements_markdown(&mut output, &[root]).unwrap();
        let markdown = String::from_utf8(output).unwrap();

        assert!(markdown.contains("# Root (ROOT)"));
        assert!(markdown.contains("[Child requirement](#child-child-1)"));
        assert!(markdown.contains("## Child (CHILD-1)"));
    }

    #[test]
    fn expands_links_to_max_depth_and_stops_ancestor_cycles() {
        let records = vec![
            record(
                "{aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa}",
                "root",
                &[
                    "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb",
                    "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb",
                ],
            ),
            record(
                "{bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb}",
                "child",
                &[
                    "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
                    "cccccccc-cccc-cccc-cccc-cccccccccccc",
                ],
            ),
            record("{cccccccc-cccc-cccc-cccc-cccccccccccc}", "grandchild", &[]),
        ];
        let guid_to_index = records
            .iter()
            .enumerate()
            .map(|(index, record)| (normalize_guid(record.guid.as_deref().unwrap()), index))
            .collect::<HashMap<_, _>>();

        let root = build_requirement(0, 0, 2, &records, &guid_to_index, &mut HashSet::new());

        assert_eq!(root.linked_requirements.len(), 2);
        assert_eq!(root.linked_requirements[0].name, "child");
        assert_eq!(
            root.linked_requirements[0]
                .linked_requirements
                .iter()
                .map(|req| req.name.as_str())
                .collect::<Vec<_>>(),
            ["root", "grandchild"]
        );
        assert!(
            root.linked_requirements[0].linked_requirements[0]
                .linked_requirements
                .is_empty()
        );
    }

    #[test]
    fn zero_max_depth_keeps_only_the_root() {
        let records = vec![
            record(
                "{aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa}",
                "root",
                &["bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"],
            ),
            record("{bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb}", "child", &[]),
        ];
        let guid_to_index = records
            .iter()
            .enumerate()
            .map(|(index, record)| (normalize_guid(record.guid.as_deref().unwrap()), index))
            .collect::<HashMap<_, _>>();

        let root = build_requirement(0, 0, 0, &records, &guid_to_index, &mut HashSet::new());

        assert!(root.linked_requirements.is_empty());
    }

    fn record(guid: &str, name: &str, link_guids: &[&str]) -> RequirementRecord {
        RequirementRecord {
            guid: Some(guid.to_string()),
            name: name.to_string(),
            alias: Some(name.to_string()),
            note: name.to_string(),
            raw_note: String::new(),
            link_guids: link_guids.iter().map(|guid| guid.to_string()).collect(),
            stereotype: None,
            truck_models: None,
            stakeholder: None,
        }
    }

    fn output_requirement(
        guid: &str,
        name: &str,
        alias: &str,
        raw_note: &str,
        linked_requirements: Vec<Requirement>,
    ) -> Requirement {
        Requirement {
            name: name.to_string(),
            alias: Some(alias.to_string()),
            note: parse_note(raw_note).text,
            stereotype: None,
            truck_models: None,
            stakeholder: None,
            linked_requirements,
            guid: Some(guid.to_string()),
            raw_note: raw_note.to_string(),
        }
    }
}
