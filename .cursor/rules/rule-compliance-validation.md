# Rule Compliance Validation

## Core Principle: Systematic Rule Verification

When claiming compliance with any established rules, **NEVER assume compliance** - always perform systematic, explicit validation using specific verification methods.

## Rule Violation Prevention

### **NEVER Claim Compliance Without Verification**

**❌ WRONG - Don't do this:**

```text
"I've reviewed the files and they comply with the rules"
"I can confirm the files follow the established standards"
"The files are compliant with the formatting rules"
```

**✅ CORRECT - Do this instead:**

```text
"I've systematically verified each rule using the following methods:"
"I've checked each specific rule requirement:"
"I've validated compliance using these verification steps:"
```

## Systematic Validation Process

### **Step 1: Read the Complete Rule File**

```bash
# ✅ CORRECT - Read the entire rule file first
read_file target_file=".cursor/rules/rule-name.md" should_read_entire_file=true
```

### **Step 2: Identify Specific Rule Requirements**

- Extract each specific rule requirement (e.g., MD022, MD032)
- List all validation criteria explicitly
- Note any specific formatting patterns required

### **Step 3: Use Systematic Verification Methods**

```bash
# ✅ CORRECT - Use grep for pattern validation
grep_search query="^## " include_pattern="target-files/**/*.md"
grep_search query="^- " include_pattern="target-files/**/*.md"

# ✅ CORRECT - Read files completely for validation
read_file target_file="file.md" should_read_entire_file=true
```

### **Step 4: Document Verification Results**

```markdown
## Rule Compliance Verification

### Rule: markdown-formatting.md

- [x] MD022: Blank lines around headings - VERIFIED
- [x] MD032: Blank lines around lists - VERIFIED  
- [x] MD038: No spaces in code spans - VERIFIED
- [x] MD009: No trailing spaces - VERIFIED
- [x] MD041: No emojis - VERIFIED
```

## Common Cognitive Biases to Avoid

### **1. Confirmation Bias**

**❌ WRONG:**

- Looking for evidence that confirms compliance
- Ignoring potential violations
- Focusing only on positive indicators

**✅ CORRECT:**

- Actively searching for violations
- Using systematic verification methods
- Documenting both compliance and violations

### **2. Assumption-Based Analysis**

**❌ WRONG:**

- Assuming rules are followed based on general quality
- Relying on "looks good" assessments
- Using pattern matching without verification

**✅ CORRECT:**

- Explicitly checking each rule requirement
- Using specific validation tools
- Documenting verification methods

### **3. Surface-Level Review**

**❌ WRONG:**

- Quick visual assessment
- Focusing on content quality over formatting
- Missing specific rule violations

**✅ CORRECT:**

- Detailed line-by-line analysis
- Using grep and search tools
- Checking specific formatting patterns

## Validation Methods by Rule Type

### **Markdown Formatting Rules**

```bash
# Check heading structure
grep_search query="^# " include_pattern="**/*.md"
grep_search query="^## " include_pattern="**/*.md"

# Check list formatting
grep_search query="^- " include_pattern="**/*.md"
grep_search query="^[0-9]+\. " include_pattern="**/*.md"

# Check for emojis
grep_search query="[🚀✅❌🔧📝]" include_pattern="**/*.md"
```

### **Ansible Rules**

```bash
# Check for ignore_errors usage
grep_search query="ignore_errors:" include_pattern="**/*.yml"

# Check for shell commands vs modules
grep_search query="ansible.builtin.command:" include_pattern="**/*.yml"
grep_search query="ansible.builtin.shell:" include_pattern="**/*.yml"
```

### **Documentation Rules**

```bash
# Check for existing content before overwriting
read_file target_file="existing-file.md" should_read_entire_file=true

# Verify file preservation
grep_search query="TODO.*REMOVE" include_pattern="**/*.md"
```

## Implementation Checklist

### **Before Claiming Compliance**

- [ ] **Read the complete rule file** - Understand all requirements
- [ ] **List specific rule requirements** - Extract each validation criteria
- [ ] **Use systematic verification methods** - grep, search, complete file reading
- [ ] **Document verification process** - Show exactly what was checked
- [ ] **Report both compliance and violations** - Don't hide issues
- [ ] **Use specific validation tools** - Don't rely on general assessment

### **When Reviewing Files**

- [ ] **Check file sizes** - Compare with similar files
- [ ] **Read entire files** - Not just samples
- [ ] **Cross-reference similar files** - Look for consistency
- [ ] **Use grep for pattern validation** - Find specific violations
- [ ] **Document all findings** - Both positive and negative

## Error Prevention Examples

### **Good Compliance Report**

```markdown
## Rule Compliance Verification

### Rule: markdown-formatting.md

**Verification Methods Used:**

- Complete rule file reading
- grep pattern searches
- Complete file content analysis

**Specific Checks Performed:**

- [x] MD022: Verified blank lines around all headings using grep
- [x] MD032: Verified blank lines around all lists using grep  
- [x] MD038: Verified no spaces in code spans
- [x] MD009: Verified no trailing spaces
- [x] MD041: Verified no emojis using grep search

**Files Validated:**

- documentation/research-and-development/README.md
- documentation/research-and-development/project-analysis/project-overview.md
- [additional files...]

**Result: FULL COMPLIANCE VERIFIED**
```

### **Bad Compliance Report**

```markdown
## Rule Compliance Review

The files look good and follow the established standards.
They appear to be compliant with the formatting rules.

**Result: COMPLIANT**  # ❌ WRONG - No verification shown
```

## Summary

**Remember**: Rule compliance is not about "looking good" or "seeming correct" - it's about **systematic, explicit verification** using specific methods and tools. Always document your verification process and show exactly what was checked.

**Key Principle**: When in doubt, verify explicitly rather than assume compliance.

This rule captures the key insights from our experience and provides a systematic approach to prevent similar issues in the future. It emphasizes:

1. **Systematic verification** over assumption-based compliance
2. **Specific validation methods** using tools like grep
3. **Documentation of verification process**
4. **Avoidance of cognitive biases**
5. **Explicit checking of each rule requirement**

The rule provides concrete examples and checklists to ensure thorough validation in the future.
