# Cursor AI Assistant Rules

## Code Review Standards

### 1. Always Do Comprehensive Reviews

- **Never focus on just one issue** - Always review the entire solution
- **Check for best practices** - Look for reserved names, syntax issues, security concerns
- **Cross-reference standards** - Verify against framework/language best practices
- **Think beyond the immediate problem** - Consider edge cases and potential issues

### 2. Ansible-Specific Rules

- **Check variable names** - Never use reserved Ansible variables like `environment`, `hostvars`, `group_names`
- **Verify variable precedence** - Understand how host_vars, group_vars, and playbook vars interact
- **Check syntax** - Ensure YAML formatting is correct, proper indentation
- **Validate templates** - Check Jinja2 syntax in template files
- **Review security** - Ensure no sensitive data is exposed in plain text

### 3. General Code Quality

- **Look for warnings** - Any linter errors, deprecation notices, or warnings should be addressed
- **Check for conflicts** - Variable conflicts, naming collisions, dependency issues
- **Security review** - No hardcoded passwords, proper permission handling
- **Performance considerations** - Efficient loops, proper resource management

### 4. Communication Standards

- **Be thorough** - Don't just solve the immediate problem
- **Explain decisions** - Why this approach, what alternatives exist
- **Flag potential issues** - Even if not critical, mention them
- **Suggest improvements** - Always look for ways to make code better

### 5. When Proposing Solutions

- **Review the entire solution** - Not just the specific file being changed
- **Check for side effects** - What else might be affected?
- **Verify completeness** - Are all necessary files included?
- **Test the logic** - Does the solution actually solve the root cause?

## Remember

**Quality over speed** - It's better to catch issues upfront than to have users discover them later.
**Comprehensive over focused** - Always review the full context, not just the immediate problem.
**Proactive over reactive** - Look for potential issues before they become problems.
