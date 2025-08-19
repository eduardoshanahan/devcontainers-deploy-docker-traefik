# Debugging and Troubleshooting Rules

## Lessons from Docker GPG Key Issue

### **1. Manual Fixes vs Ansible Automation**

**When Ansible automation fails but manual fixes work:**

**✅ DO:**

- **Document the manual fix** that worked
- **Analyze why Ansible failed** (timing, permissions, edge cases)
- **Update Ansible code** to handle the specific failure mode
- **Add fallback mechanisms** for persistent issues

**❌ DON'T:**

- Ignore the difference between manual and automated approaches
- Assume Ansible will always work the same as manual commands
- Remove features to "fix" debugging issues

**Example from our experience:**

```bash
# Manual fix that worked:
sudo apt-key del 7EA0A9C3F273FCD8
sudo rm -rf /var/lib/apt/lists/*
sudo apt-get update

# Ansible equivalent needed multiple approaches:
- name: Remove existing Docker keys (generic approach)
  ansible.builtin.command: apt-key del {{ item }}
  loop: "{{ existing_docker_keys.stdout_lines | select('match', '^pub') | map('regex_replace', '^pub.*([A-F0-9]{16}).*', '\\1') | list }}"
  when: existing_docker_keys.stdout_lines | length > 0
  failed_when: false
  changed_when: false
```

### **2. Persistent Error Patterns**

**When the same error keeps occurring:**

**✅ DO:**

- **Identify the root cause** (not just the symptom)
- **Check multiple locations** where the issue might be cached
- **Use multiple cleanup methods** (files, cache, keyring)
- **Add comprehensive logging** to track what's happening

**❌ DON'T:**

- Keep trying the same approach that failed
- Assume the error is "fixed" after one cleanup attempt
- Ignore system-specific caching mechanisms

**Example:**

```yaml
# Comprehensive cleanup approach
- name: Remove from apt keyring
  ansible.builtin.command: apt-key del {{ item }}

- name: Remove from file system
  ansible.builtin.file:
    path: "{{ item }}"
    state: absent

- name: Clear all caches
  ansible.builtin.command: rm -rf /var/lib/apt/lists/*
```

### **3. Fallback Strategies**

**Always have multiple approaches:**

**✅ DO:**

- **Try direct installation first** (bypass problematic steps)
- **Have manual fallback methods** (shell commands)
- **Use `failed_when: false`** instead of `ignore_errors`
- **Register results** to check what actually worked

**❌ DON'T:**

- Rely on a single installation method
- Use `ignore_errors` without proper handling
- Assume one approach will work everywhere

**Example:**

```yaml
- name: Try direct installation
  ansible.builtin.apt:
    name: docker-ce
    state: present
  register: direct_install
  failed_when: false

- name: Fallback to manual repository addition
  when: direct_install is failed
  block:
    - name: Add repository manually
      ansible.builtin.shell: echo "deb ..." | sudo tee /etc/apt/sources.list.d/docker.list
```

### **4. System-Specific Issues**

**Ubuntu/Docker specific patterns:**

**✅ DO:**

- **Check for existing installations** before adding new ones
- **Handle different Ubuntu versions** (old vs new keyring methods)
- **Clear all possible cache locations**
- **Use explicit key verification** in repository configs

**❌ DON'T:**

- Assume all systems are clean
- Ignore version-specific differences
- Use deprecated methods (like old apt-key)

**Example:**

```yaml
# Handle both old and new Ubuntu keyring methods
- name: Remove old method keys
  ansible.builtin.file:
    path: /etc/apt/trusted.gpg.d/docker.gpg
    state: absent

- name: Remove new method keys
  ansible.builtin.file:
    path: /etc/apt/keyrings/docker.gpg
    state: absent
```

### **5. Debugging Workflow**

**When debugging persistent issues:**

1. **✅ Identify the exact error pattern**

   ```text
   NO_PUBKEY 7EA0A9C3F273FCD8
   ```

2. **✅ Find what manual fix works**

   ```bash
   sudo apt-key del 7EA0A9C3F273FCD8
   sudo rm -rf /var/lib/apt/lists/*
   sudo apt-get update
   ```

3. **✅ Analyze why Ansible failed**
   - Different timing
   - Permission issues
   - Caching problems
   - Edge cases

4. **✅ Update Ansible code with multiple approaches**
   - Direct installation
   - Manual fallback
   - Comprehensive cleanup

5. **✅ Test thoroughly**
   - Verify all features still work
   - Test on different systems
   - Document the solution

### **6. Code Quality During Debugging**

**Maintain code quality even when debugging:**

**✅ DO:**

- **Fix linter errors** even during debugging
- **Use proper Ansible modules** instead of shell commands
- **Add proper error handling** with `failed_when` and `changed_when`
- **Document temporary changes** clearly

**❌ DON'T:**

- Ignore linter warnings
- Use shell commands when modules exist
- Leave temporary debugging code in production

**Example:**

```yaml
# ✅ Good - Proper error handling
- name: Remove problematic key
  ansible.builtin.command: apt-key del {{ item }}
  failed_when: false
  changed_when: false

# ❌ Bad - Ignoring errors
- name: Remove problematic key
  ansible.builtin.command: apt-key del {{ item }}
  ignore_errors: true
```

### **7. Documentation of Solutions**

**Always document what worked:**

**✅ DO:**

- **Document the manual fix** that resolved the issue
- **Explain why the original approach failed**
- **Update the code** to prevent future occurrences
- **Add comments** explaining the workaround

**Example:**

```yaml
# This approach handles persistent GPG key conflicts
# that occur when Docker was previously installed using
# different methods or on upgraded Ubuntu systems
- name: Remove existing Docker keys (generic approach)
  ansible.builtin.command: apt-key del {{ item }}
  loop: "{{ existing_docker_keys.stdout_lines | select('match', '^pub') | map('regex_replace', '^pub.*([A-F0-9]{16}).*', '\\1') | list }}"
  when: existing_docker_keys.stdout_lines | length > 0
  failed_when: false
  changed_when: false
```

### **8. Testing After Fixes**

**Always verify the fix works:**

**✅ DO:**

- **Test the deployment** after fixes
- **Verify all features** still work
- **Test on different systems** if possible
- **Document the successful approach**

**❌ DON'T:**

- Assume the fix works without testing
- Skip verification steps
- Ignore edge cases

### **Implementation Checklist**

**When debugging persistent issues:**

- [ ] **Identify the exact error pattern**
- [ ] **Find a working manual fix**
- [ ] **Analyze why Ansible failed**
- [ ] **Implement multiple fallback approaches**
- [ ] **Fix all linter errors**
- [ ] **Test thoroughly**
- [ ] **Document the solution**
- [ ] **Update rules to prevent recurrence**

**Remember**: The goal is to **solve the problem permanently** while maintaining code quality and preventing future occurrences.
