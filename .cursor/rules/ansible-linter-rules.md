# Ansible Linter Rules

## Use failed_when Instead of ignore_errors

### **Core Principle: Explicit Error Handling**

When handling potential failures in Ansible tasks, **NEVER use `ignore_errors: true`**. Instead, use `failed_when` to explicitly specify when a task should be considered failed.

### **Rule: Replace ignore_errors with failed_when**

**❌ WRONG - Don't do this:**
```yaml
- name: Test configuration
  ansible.builtin.command: some-command
  ignore_errors: true
```

**✅ CORRECT - Do this instead:**
```yaml
- name: Test configuration
  ansible.builtin.command: some-command
  failed_when: false
```

### **Common Patterns**

**For configuration tests that shouldn't fail deployment:**
```yaml
- name: Test rsyslog configuration
  ansible.builtin.command: rsyslogd -N1
  failed_when: false
```

**For optional operations:**
```yaml
- name: Optional cleanup
  ansible.builtin.file:
    path: /tmp/old-file
    state: absent
  failed_when: false
```

**For commands that might fail but shouldn't stop deployment:**
```yaml
- name: Check service status
  ansible.builtin.command: systemctl status optional-service
  failed_when: false
  changed_when: false
```

### **Benefits of failed_when**

1. **Explicit intent** - Clear about when failure is acceptable
2. **Linter compliance** - Satisfies ansible-lint requirements
3. **Better debugging** - Easier to understand what's happening
4. **Consistent code** - Standardized error handling approach

### **Implementation**

**When writing or editing Ansible tasks:**

1. **Never use `ignore_errors: true`**
2. **Always use `failed_when` with explicit conditions**
3. **Use `failed_when: false` for optional/ignorable operations**
4. **Use `failed_when: result.rc != 0` for specific error conditions**

This rule ensures consistent, linter-compliant Ansible code with explicit error handling.
