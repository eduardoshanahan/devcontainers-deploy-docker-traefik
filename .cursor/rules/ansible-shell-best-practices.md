# Ansible Shell Best Practices

## Rule

When using `ansible.builtin.shell` module, always follow shell best practices including pipefail option, proper error handling, line length limits, and security considerations.

## Quick Reference

**Essential Requirements:**

- ✅ Use `set -eo pipefail` for commands with pipes
- ✅ Keep lines under 160 characters
- ✅ Add `changed_when: false` for read-only operations
- ✅ Add `failed_when: false` for commands that may legitimately fail
- ✅ Quote all variables: `"{{ variable }}"`
- ✅ Provide fallback values: `|| echo "default"`

## Detailed Guidelines

### 1. Pipefail Requirement

**Always use `set -eo pipefail` for shell commands that use pipes:**

```yaml
# ❌ WRONG - Missing pipefail
- name: Parse fail2ban statistics
  ansible.builtin.shell: |
    set -e
    current_banned=$(fail2ban-client status sshd | grep "Currently banned" | awk '{print $4}')

# ✅ CORRECT - With pipefail
- name: Parse fail2ban statistics
  ansible.builtin.shell: |
    set -eo pipefail
    current_banned=$(fail2ban-client status sshd | grep "Currently banned" | awk '{print $4}')
```

**Why pipefail matters:**

- Without pipefail, `command1 | command2` only fails if `command2` fails
- With pipefail, the entire pipeline fails if ANY command fails
- Critical for data processing pipelines where intermediate failures must be caught

### 2. Line Length Management

**Keep lines under 160 characters. Use YAML folded scalars and line continuations:**

```yaml
# ❌ WRONG - Line too long
- name: Display status
  ansible.builtin.debug:
    msg: "Service status: {{ ansible_facts.services['service.name'].state if 'service.name' in ansible_facts.services else 'Not found' }}"

# ✅ CORRECT - Using folded scalar
- name: Display status
  ansible.builtin.debug:
    msg: >-
      Service status: {{
        ansible_facts.services['service.name'].state
        if 'service.name' in ansible_facts.services
        else 'Not found'
      }}

# ✅ ALSO CORRECT - Shell command with line continuation
- name: Process data with long pipeline
  ansible.builtin.shell: |
    set -eo pipefail
    result=$(command1 | \
             command2 --long-option value | \
             command3 --another-long-option)
```

### 3. Standard Shell Command Structure

**Use this template for all shell commands:**

```yaml
- name: Descriptive task name
  ansible.builtin.shell: |
    set -eo pipefail
    
    # Optional: Set additional variables
    readonly VAR_NAME="value"
    
    # Your commands here with error handling
    if condition; then
      result=$(command1 | command2 || echo "fallback")
    else
      result="default"
    fi
    
    # Output structured data for Ansible parsing
    echo "key1=${result}"
    echo "key2=${other_value}"
  register: command_output
  changed_when: false  # For read-only operations
  failed_when: false   # If command may legitimately fail
```

### 4. Error Handling Patterns

**Always include appropriate error handling:**

```yaml
# Pattern A: Command that should never fail
- name: Get system information
  ansible.builtin.shell: |
    set -eo pipefail
    echo "hostname=$(hostname)"
    echo "uptime=$(uptime -p)"
  register: system_info
  changed_when: false

# Pattern B: Command that might fail (use failed_when: false)
- name: Check service status
  ansible.builtin.shell: |
    set -eo pipefail
    if systemctl is-active service >/dev/null 2>&1; then
      echo "status=active"
    else
      echo "status=inactive"
    fi
  register: service_status
  changed_when: false
  failed_when: false

# Pattern C: Command with custom failure conditions
- name: Check disk space
  ansible.builtin.shell: |
    set -eo pipefail
    usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    echo "disk_usage=${usage}"
  register: disk_check
  changed_when: false
  failed_when: disk_check.stdout_lines | select('match', '^disk_usage=.*') | first | default('disk_usage=0') | regex_replace('^disk_usage=', '') | int > 90
```

### 5. Security and Safety

**Protect against injection and handle sensitive data:**

```yaml
# ✅ CORRECT - Proper variable quoting
- name: Process user input safely
  ansible.builtin.shell: |
    set -eo pipefail
    result=$(grep "{{ user_input | quote }}" /var/log/app.log || echo "not found")
    echo "result=${result}"

# ✅ CORRECT - Handle sensitive data
- name: Check database connection
  ansible.builtin.shell: |
    set -eo pipefail
    # Don't echo sensitive values
    if mysql -u "{{ db_user }}" -p"{{ db_password }}" -e "SELECT 1" >/dev/null 2>&1; then
      echo "status=connected"
    else
      echo "status=failed"
    fi
  register: db_check
  changed_when: false
  failed_when: false
  no_log: true  # Prevent logging of sensitive data
```

### 6. Variable Handling

**Safe variable usage patterns:**

```yaml
# ✅ CORRECT - With fallbacks and proper quoting
- name: Parse configuration value
  ansible.builtin.shell: |
    set -eo pipefail
    config_file="{{ config_path | default('/etc/app/config.yml') }}"
    if [ -f "${config_file}" ]; then
      value=$(grep "^setting:" "${config_file}" | cut -d: -f2 | tr -d ' ' || echo "default")
    else
      value="default"
    fi
    echo "setting=${value}"
  register: config_value
  changed_when: false
```

### 7. Shell Options Reference

| Option | Purpose | When to Use | Example |
|--------|---------|-------------|---------|
| `set -e` | Exit on error | Always | `set -eo pipefail` |
| `set -o pipefail` | Fail on pipe errors | When using pipes (`\|`) | `cmd1 \| cmd2` |
| `set -u` | Exit on undefined variables | When strict checking needed | `set -euo pipefail` |
| `set -x` | Debug mode | Troubleshooting only | `set -exo pipefail` |

### 8. Common Anti-Patterns to Avoid

```yaml
# ❌ ANTI-PATTERN 1: No error handling
- name: Bad example
  ansible.builtin.shell: command1 | command2

# ❌ ANTI-PATTERN 2: Unquoted variables
- name: Bad example
  ansible.builtin.shell: grep {{ user_input }} /var/log/app.log

# ❌ ANTI-PATTERN 3: No fallback values
- name: Bad example
  ansible.builtin.shell: |
    result=$(command_that_might_fail)
    echo $result

# ❌ ANTI-PATTERN 4: Mixing shell and Ansible logic
- name: Bad example
  ansible.builtin.shell: |
    if [ "{{ ansible_os_family }}" = "RedHat" ]; then
      yum install package
    fi
  # Use when: ansible_os_family == "RedHat" instead
```

### 9. Testing Shell Commands

**Before adding shell commands to playbooks:**

1. **Test independently**: Run commands on target system first
2. **Check exit codes**: Verify proper error handling
3. **Test edge cases**: Empty outputs, missing files, etc.
4. **Validate parsing**: Ensure Ansible can parse the output correctly

```bash
# Test shell command independently
bash -c 'set -eo pipefail; your_command_here'
echo "Exit code: $?"
```

### 10. Best Practices Checklist

Before committing shell commands in Ansible:

- [ ] **Pipefail**: Added `set -eo pipefail` for commands with pipes
- [ ] **Line length**: All lines under 160 characters  
- [ ] **Error handling**: Proper `failed_when` and `changed_when` conditions
- [ ] **Variable safety**: Used quotes around variables: `"{{ variable }}"`
- [ ] **Fallback values**: Provided fallbacks with `|| echo "default"`
- [ ] **Security**: No injection vulnerabilities, sensitive data protected
- [ ] **Readability**: Complex commands have comments
- [ ] **Testing**: Commands tested independently before integration

### 11. Integration with Development Tools

This rule addresses issues caught by:

- **ansible-lint**: Shell best practices, pipefail warnings
- **yamllint**: Line length violations, YAML formatting
- **shellcheck**: Shell script security and correctness
- **IDE linters**: Syntax highlighting and error detection

### 12. Troubleshooting Common Issues

#### **Issue: "Pipefail required" lint error**

```yaml
# Solution: Add pipefail to shell commands with pipes
ansible.builtin.shell: |
  set -eo pipefail  # Add this line
  command1 | command2
```

#### **Issue: "Line too long" lint error**

```yaml
# Solution: Use folded scalar or line continuation
msg: >-
  Long message split across
  multiple lines for readability
```

#### **Issue: Shell command always shows "changed"**

```yaml
# Solution: Add changed_when for read-only operations
register: result
changed_when: false  # Add this for read-only commands
```

## Implementation Guidelines

When writing or reviewing Ansible playbooks:

1. **Review every shell command** for compliance with this rule
2. **Use the standard template** for consistent structure
3. **Test shell commands** independently before integration
4. **Document complex logic** with inline comments
5. **Consider alternatives** - use Ansible modules when possible

This ensures consistent, reliable, secure, and maintainable Ansible shell commands across the entire project.
