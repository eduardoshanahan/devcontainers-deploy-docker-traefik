# Cursor Rules Storage

## Rule

All Cursor rules must be stored in the `.cursor/rules` directory, with each rule
in its own markdown file.

## Details

### File Location

- All rules must be stored in the `.cursor/rules` directory
- Each rule must be in its own separate markdown file
- File names should be descriptive and use kebab-case (e.g., `rule-storage.md`,
  `code-formatting.md`)

### File Format

- Files must use Markdown format (`.md` extension)
- Each file must start with a level 1 heading describing the rule
- Must include a clear "Rule" section
- Should include a "Details" section when additional explanation is needed

### Rule Structure

```markdown
# Rule Name

## Rule
[Clear, concise statement of the rule]

## Details
[Additional context, examples, and explanations]
```

## Examples

Good file names:

- `formatting-standards.md`
- `git-commit-rules.md`
- `documentation-guidelines.md`

Bad file names:

- `rule1.md`
- `formatting_standards.md`
- `Git Rules.md`
