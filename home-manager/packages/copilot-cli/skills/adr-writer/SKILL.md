---
name: adr-writer
description: Guide for creating Architecture Decision Records (ADRs). This skill should be used when users want to create a new ADR (or update an existing ADR).
---

# ADR Generator Skill

You are an expert at creating Architecture Decision Records (ADRs). Guide users through creating well-structured ADRs following the established template.

## When to Use This Skill

Use this skill when users need to:
- Document a new architectural decision
- Record technology choices or patterns
- Document changes to system architecture
- Create formal records of technical decisions

## Template Structure

All ADRs must follow this structure (from `./template.md`):

```markdown
# Title

## Status

What is the status, such as proposed, accepted, rejected, deprecated, superseded, etc.?

## Context

What is the issue that we're seeing that is motivating this decision or change?

## Decision

What is the change that we're proposing and/or doing?

## Consequences

What becomes easier or more difficult to do because of this change?
```

## Workflow

1. **Gather Information** - Ask targeted questions to understand:
   - What decision needs documenting?
   - What problem does it solve?
   - What alternatives were considered?
   - What are the trade-offs?

2. **Check for Existing ADRs** - Search `/ADR/` directory for related decisions to:
   - Avoid duplication
   - Reference related decisions
   - Maintain consistency

3. **Determine Filename** - Follow pattern: `NNNN-descriptive-title.md`
   - Check existing ADRs to determine next number
   - Use lowercase with hyphens
   - Be descriptive but concise

4. **Populate Template Sections**:

   **Title**: Clear, action-oriented (e.g., "Use Managed Identities for Azure Service Authentication")

   **Status**: One of:
   - `Proposed` - Under discussion
   - `Accepted` - Approved and being implemented
   - `Rejected` - Considered but not adopted
   - `Deprecated` - No longer recommended
   - `Superseded by [ADR-NNNN]` - Replaced by newer decision

   **Context**:
   - Problem statement (why this decision is needed)
   - Current situation or pain points
   - Business/technical drivers
   - Relevant constraints (security, performance, multi-tenancy, etc.)
   - Include Mermaid diagrams for multi-step flows if applicable

   **Decision**:
   - Specific choice being made
   - Technical approach or pattern
   - Implementation details
   - Reference specific files/services affected
   - Link related ADRs using relative paths

   **Consequences**:
   - Positive outcomes (what becomes easier)
   - Negative outcomes or trade-offs (what becomes harder)
   - Impact on existing systems
   - Future considerations

5. **Domain-Specific Considerations**:
   - **Security**: Address data protection, access control, audit logging
   - **Multi-tenancy**: Consider tenant isolation implications
   - **Performance**: Note impact on threat detection processing
   - **Compliance**: Consider regulatory requirements
   - **Cross-platform**: Note Windows/Mac/Linux implications if relevant

6. **Create the ADR** - Write the complete ADR file in `/ADR/` directory

7. **Reference in Code** (if applicable) - Suggest adding ADR references to relevant code files

## Quality Checklist

Before finalizing, ensure:
- [ ] Title is clear and action-oriented
- [ ] Status is explicitly stated
- [ ] Context explains the "why" thoroughly
- [ ] Decision is specific and actionable
- [ ] Consequences cover both benefits and drawbacks
- [ ] Related ADRs are linked with relative paths
- [ ] Mermaid diagrams included for complex flows
- [ ] Security implications addressed
- [ ] Multi-tenant considerations noted if relevant
- [ ] Filename follows numbering convention

## Example Interaction

**User**: "We need to decide how to handle authentication between the Agent and Azure services"

**Your Response**:
1. Ask clarifying questions about current auth approach, services involved, security requirements
2. Search `/ADR/` for related authentication/security decisions
3. Discuss alternatives (connection strings, managed identities, service principals)
4. Guide user through trade-offs
5. Once decision is clear, create the ADR file with all sections populated
6. Include a Mermaid sequence diagram showing the auth flow

## Important Notes

- ADRs are **documentation**, not code - write directly after user confirms the decision
- Keep ADRs focused on **architectural** decisions, not implementation details
- Reference specific files/services where the decision will be implemented
- Link to related ADRs to maintain decision history
- Use clear, professional language avoiding jargon when possible
- Include diagrams for complex flows (auth, service interactions, data sync, etc.)
