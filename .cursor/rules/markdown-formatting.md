# Markdown Formatting Standards

## Overview

This rule ensures all markdown files follow consistent formatting standards and avoid common linting issues.

## Heading Structure

- Use proper heading hierarchy: `#` → `##` → `###` → `####`
- Never skip heading levels (e.g., don't go from `#` directly to `###`)
- Use only one `#` (h1) per document
- Use descriptive heading text
- **Always surround headings with blank lines** (MD022 rule)
  - One blank line before each heading
  - One blank line after each heading
  - This ensures proper parsing and readability

## Code Blocks

- Use triple backticks with language specification: ```bash
- For inline code, use single backticks: `code`
- **No spaces inside code spans** (MD038 rule)
  - Correct: `command`
  - Incorrect: ` command `
- Ensure code blocks are properly closed
- Use proper indentation within code blocks

## Lists

- Use consistent list markers (`-` for unordered, `1.` for ordered)
- Maintain proper indentation (2 spaces per level)
- Don't mix list types without clear hierarchy
- Ensure list items are properly spaced
- **Always surround lists with blank lines** (MD032 rule)
  - One blank line before each list
  - One blank line after each list

## Links and References

- Use proper markdown link syntax: `[text](url)`
- For internal links, use proper anchor references
- Ensure all links are valid and accessible
- Use descriptive link text

## Tables

- Use proper table syntax with headers and alignment
- Align columns appropriately (`|:---|` for left, `|:---:|` for center, `|---:|` for right)
- Ensure all rows have the same number of columns
- Use descriptive header text

## Line Length and Formatting

- Keep lines under 120 characters when possible
- Use proper line breaks for readability
- **No trailing spaces** (MD009 rule)
  - Use 0 or 2 spaces, never 1
  - This affects line continuation in markdown
- Use consistent spacing around headings, lists, and code blocks

## Images

- Always include alt text for accessibility
- Use descriptive alt text
- Ensure images are properly sized and formatted

## Emojis and Special Characters

- **No emojis in markdown content** (MD041 rule)
  - Avoid using emoji characters (🚀, ✅, ❌, etc.)
  - Use text-based alternatives instead
  - Examples:
    - Instead of ✅, use "✓" or "PASS"
    - Instead of ❌, use "✗" or "FAIL"
    - Instead of , use "DEPLOY" or "LAUNCH"
    - Instead of , use "FIX" or "CONFIGURE"
- Use standard ASCII characters when possible
- Maintain professional documentation standards
- Ensure compatibility across different platforms and tools

## Common Issues to Avoid

- Don't use HTML tags unless absolutely necessary
- Avoid excessive bold or italic formatting
- Don't use deprecated markdown syntax
- Ensure proper escaping of special characters
- **Avoid emoji usage** for better compatibility and professionalism

## Examples

### Good Heading Structure

```markdown
# Main Title

## Section

### Subsection

#### Detail
```

### Good Code Blocks

```bash
./launch.sh
```

Inline code: `command`

### Good Lists

```markdown
- First item
  - Nested item
- Second item
  1. Numbered sub-item
  2. Another sub-item
```

### Good Tables

```markdown
| Column 1 | Column 2 | Column 3 |
|:---------|:--------:|---------:|
| Left     | Center   | Right    |
| Data     | Data     | Data     |
```

### Good Text Alternatives (No Emojis)

```markdown
# Project Status: PRODUCTION READY

## Security Features
- ✓ SSH Hardening
- ✓ Firewall Configuration
- ✗ Vulnerabilities Found
- DEPLOY: Container Security Scanning
- CONFIGURE: Network Isolation
```

## Validation Checklist

Before committing markdown files, ensure:

- [ ] Proper heading hierarchy
- [ ] **Blank lines around all headings (MD022)**
- [ ] **No spaces inside code spans (MD038)**
- [ ] **Blank lines around all lists (MD032)**
- [ ] **No trailing spaces (MD009)**
- [ ] **File ends with single newline (MD047)**
- [ ] **No emojis in content (MD041)**
- [ ] Consistent code block formatting
- [ ] Proper list indentation
- [ ] Valid links and references
- [ ] Proper table formatting
- [ ] Reasonable line lengths
- [ ] Alt text for images
- [ ] Consistent spacing
- [ ] Professional text-based alternatives for status indicators
