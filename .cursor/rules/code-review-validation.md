# Code Review and Validation Rules

## File Integrity Validation

### Before Declaring Files "Created and Correct"

**MUST perform these checks for every file:**

1. **File Size Validation**
   - Compare file sizes with similar files in the same directory
   - Flag files that are significantly larger or smaller than expected
   - Example: Template files should be similar in size (within 50% range)

2. **Complete File Reading**
   - Read entire files, not just samples
   - Use `should_read_entire_file: true` for all file validations
   - Never rely on partial file content for validation

3. **Content Integrity Checks**
   - Verify file content matches intended purpose
   - Check for corrupted or misplaced content
   - Ensure no cross-contamination between files

4. **Cross-Reference Validation**
   - Compare similar files for consistency
   - Verify template variables are properly referenced
   - Check that file dependencies are correctly linked

### Template File Validation

**For all template files (.j2):**

1. **Size Comparison**

   ```bash
   # Check file sizes
   wc -l src/roles/*/templates/*.j2
   # Flag files that are outliers
   ```

2. **Content Validation**
   - Verify templates contain appropriate Jinja2 syntax
   - Check for misplaced YAML/Ansible content in shell scripts
   - Ensure no playbook content in template files

3. **Variable Reference Check**
   - Verify all template variables are defined in defaults
   - Check for undefined variable references
   - Ensure proper fallback values are set

### Ansible Role Validation

**For all Ansible roles:**

1. **Directory Structure**
   - Verify all required directories exist
   - Check file permissions and ownership
   - Ensure consistent naming conventions

2. **File Dependencies**
   - Verify all referenced files exist
   - Check that template sources match destinations
   - Ensure no broken file references

3. **Variable Consistency**
   - Cross-reference variables between defaults and tasks
   - Verify variable inheritance works correctly
   - Check for undefined variable usage

### Deployment Validation

**Before declaring deployment ready:**

1. **Playbook Integration**
   - Verify roles are properly included in playbooks
   - Check that variable passing works correctly
   - Ensure no conflicting variable definitions

2. **Template Rendering**
   - Test template rendering with sample data
   - Verify no syntax errors in generated files
   - Check that all variables are properly substituted

3. **Error Prevention**
   - Look for common Ansible errors (undefined variables, missing files)
   - Verify all required packages are included
   - Check for proper error handling

## Review Checklist

### Before Declaring Files "Created and Correct"

- [ ] **File Size Check**: All files are appropriate size for their type
- [ ] **Complete Content Review**: Read entire files, not samples
- [ ] **Cross-Reference**: Compare similar files for consistency
- [ ] **Variable Validation**: All template variables are defined
- [ ] **Syntax Check**: No syntax errors in templates or YAML
- [ ] **Dependency Check**: All referenced files exist
- [ ] **Integration Test**: Files work together properly

### Red Flags to Watch For

1. **File Size Anomalies**
   - Files much larger/smaller than similar files
   - Template files with hundreds of lines when others have dozens

2. **Content Mismatch**
   - Shell scripts containing YAML content
   - Template files with playbook content
   - Wrong file types in wrong directories

3. **Variable Issues**
   - Undefined variable references
   - Missing default values
   - Incorrect variable inheritance

4. **Structural Problems**
   - Missing directories or files
   - Incorrect file permissions
   - Broken file references

## Validation Commands

### File Size Analysis

```bash
# Check file sizes in a directory
find src/roles/configure_reporting/templates/ -name "*.j2" -exec wc -l {} \;

# Compare with similar roles
find src/roles/configure_monitoring/templates/ -name "*.j2" -exec wc -l {} \;
```

### Content Validation

```bash
# Check for undefined variables
grep -r "{{.*}}" src/roles/configure_reporting/templates/ | grep -v "default("

# Check for misplaced content
grep -r "ansible.builtin" src/roles/configure_reporting/templates/

# Check for playbook content in templates
grep -r "hosts:" src/roles/configure_reporting/templates/
```

### Template Syntax Check

```bash
# Validate Jinja2 syntax
python3 -c "from jinja2 import Template; Template(open('template.j2').read())"
```

## Error Prevention

### Common Mistakes to Avoid

1. **Partial File Reading**
   - ❌ Only reading first 50 lines
   - ✅ Read entire files for validation

2. **Size Ignorance**
   - ❌ Not checking file sizes
   - ✅ Compare file sizes with similar files

3. **Content Assumption**
   - ❌ Assuming content is correct based on structure
   - ✅ Verify actual content matches purpose

4. **Cross-Reference Skipping**
   - ❌ Not comparing similar files
   - ✅ Always cross-reference for consistency

## Implementation

### When Creating New Files

1. **Create the file**
2. **Read the entire file** to verify content
3. **Compare with similar files** for size and structure
4. **Test template rendering** if applicable
5. **Verify variable references** are defined
6. **Check for syntax errors**
7. **Only then declare it "created and correct"**

### When Reviewing Existing Files

1. **Read entire files** (not samples)
2. **Check file sizes** against similar files
3. **Verify content integrity** (no corruption)
4. **Cross-reference** with similar files
5. **Test functionality** if possible
6. **Report any anomalies** immediately

This rule ensures thorough validation and prevents the kind of oversight that led to the corrupted template file.
