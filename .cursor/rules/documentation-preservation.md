# Documentation Preservation Rules

## Never Overwrite Existing Documentation Without Reading It First

### **Core Principle: Preserve and Enhance**

When updating or creating documentation, **NEVER overwrite existing files** without first reading and understanding their content. The goal is to **preserve valuable information** while adding new features.

### **Documentation Update Process**

#### **1. ALWAYS Read Existing Documentation First**

```bash
# ✅ CORRECT - Read existing file first
read_file target_file="path/to/existing/file.md" should_read_entire_file=true

# ❌ WRONG - Don't create new content without reading existing
# Creating new documentation without checking what already exists
```

#### **2. Merge Strategy: Preserve + Enhance**

**When updating documentation:**

**✅ DO:**

- Read the entire existing file first
- Identify valuable information to preserve
- Add new content while maintaining existing structure
- Update sections that need enhancement
- Preserve all examples, troubleshooting, and technical details
- Mark new features clearly (e.g., "**NEW**: Feature description")

**❌ DON'T:**

- Overwrite existing files without reading them
- Assume new content is better than existing content
- Remove valuable troubleshooting information
- Delete useful examples or configuration samples
- Ignore existing variable documentation

#### **3. Documentation Merge Checklist**

**Before creating/updating any documentation file:**

- [ ] **Read the entire existing file** (if it exists)
- [ ] **Identify all valuable content** to preserve
- [ ] **Note the existing structure** and organization
- [ ] **List all examples and code samples** to keep
- [ ] **Identify troubleshooting sections** to maintain
- [ ] **Check for configuration examples** to preserve
- [ ] **Review variable documentation** to keep
- [ ] **Plan how to integrate new features** without losing existing info

#### **4. Content Preservation Categories**

**ALWAYS preserve these types of content:**

**Technical Details:**

- Configuration examples
- Variable explanations
- Troubleshooting steps
- Security considerations
- Best practices

**User Experience:**

- Usage examples
- Command-line examples
- Step-by-step instructions
- Common use cases
- Error resolution

**Reference Information:**

- Version compatibility
- Dependencies
- Requirements
- Limitations
- Known issues

#### **5. New Content Integration**

**When adding new features:**

```markdown
# ✅ CORRECT - Preserve existing + add new

## Existing Section (Preserved)
[Keep all existing content]

## NEW: New Feature Section
[Add new feature documentation]

## Updated Section (Enhanced)
[Existing content + new enhancements]
```

#### **6. Version Control for Documentation**

**Before making documentation changes:**

```bash
# ✅ CORRECT - Check what exists
git status
git diff path/to/file.md

# ✅ CORRECT - Read existing content
read_file target_file="path/to/file.md" should_read_entire_file=true
```

#### **7. Documentation Review Process**

**After updating documentation:**

- [ ] **Verify all existing content is preserved**
- [ ] **Check that new features are clearly marked**
- [ ] **Ensure examples still work**
- [ ] **Validate that troubleshooting steps are intact**
- [ ] **Confirm variable documentation is complete**
- [ ] **Test that the structure is logical**

### **Examples of Good Documentation Updates**

#### **Before (Existing Content)**

```markdown
## Configuration
- Feature A configuration
- Feature B settings
- Troubleshooting steps
```

#### **After (Preserved + Enhanced)**

```markdown
## Configuration
- Feature A configuration
- Feature B settings
- **NEW**: Feature C configuration
- Troubleshooting steps
- **NEW**: Feature C troubleshooting
```

### **Common Mistakes to Avoid**

1. **Overwriting without reading** - Always read existing files first
2. **Assuming new is better** - Existing content often has valuable insights
3. **Removing troubleshooting** - Users rely on existing solutions
4. **Deleting examples** - Examples help users understand usage
5. **Ignoring structure** - Existing organization often makes sense

### **When Documentation Conflicts**

**If new and existing documentation seem to conflict:**

1. **Analyze both versions** - Understand the differences
2. **Identify the best approach** - Merge or choose the better version
3. **Preserve valuable parts** - Keep useful information from both
4. **Document the changes** - Explain why changes were made
5. **Test the result** - Ensure the merged documentation works

### **Summary**

**Remember: Documentation is cumulative knowledge.** Each update should **preserve existing value** while **adding new insights**. Never assume that new content automatically replaces old content - often the best result comes from **preserving and enhancing** what already exists.

### **Key Rule: Read First, Preserve Always, Enhance Carefully**
