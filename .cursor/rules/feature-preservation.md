# Feature Preservation Rules

## Never Remove Existing Features During Debugging

### **Core Principle: Add, Don't Subtract**

When debugging or fixing issues, **NEVER remove existing features** that were intentionally created. The goal is to **improve and enhance**, not **devolve or remove**.

### **Debugging Process Rules**

#### **1. Temporary Changes Only**

```yaml
# ✅ CORRECT - Temporary debugging
- name: Debug Docker installation
  ansible.builtin.debug:
    msg: "Testing Docker GPG key"
  when: debug_mode | default(false)

# ❌ WRONG - Removing features
- name: Remove Docker security config  # DON'T DO THIS
  ansible.builtin.file:
    path: /etc/docker/daemon.json
    state: absent
```

#### **2. Feature Preservation Checklist**

**Before making ANY changes, verify these features are preserved:**

- [ ] **Security configurations** - All security settings intact
- [ ] **Network configurations** - All network features maintained
- [ ] **Monitoring systems** - All monitoring features working
- [ ] **Logging systems** - All logging features preserved
- [ ] **User permissions** - All user access maintained
- [ ] **Service configurations** - All services properly configured
- [ ] **Template files** - All templates with full functionality
- [ ] **Cron jobs** - All scheduled tasks maintained
- [ ] **Email notifications** - All notification systems working
- **Reporting systems** - All reporting features intact

#### **3. Debugging Workflow**

**Step 1: Identify the Issue**

```bash
# Don't remove features, add debugging
- name: Debug the specific issue
  ansible.builtin.debug:
    msg: "Current configuration: {{ item }}"
  loop: "{{ current_config }}"
```

**Step 2: Add Temporary Debugging**

```yaml
# ✅ Add debugging without removing features
- name: Debug Docker GPG key
  ansible.builtin.command: ls -la /etc/apt/keyrings/
  register: debug_gpg
  changed_when: false

- name: Show debug info
  ansible.builtin.debug:
    msg: "{{ debug_gpg.stdout }}"
```

**Step 3: Fix the Issue**

```yaml
# ✅ Fix the issue while preserving all features
- name: Fix GPG key issue
  ansible.builtin.get_url:
    url: https://download.docker.com/linux/ubuntu/gpg
    dest: /etc/apt/keyrings/docker.gpg
    mode: "0644"
  # Keep all existing security configurations
```

**Step 4: Verify All Features Still Work**

```yaml
# ✅ Test that all features are preserved
- name: Verify Docker security config
  ansible.builtin.stat:
    path: /etc/docker/daemon.json
  register: docker_config

- name: Verify monitoring is working
  ansible.builtin.service:
    name: monitoring
    state: started
```

#### **4. Feature Inventory System**

**Create a feature inventory for each role:**

```yaml
# src/roles/deploy_docker/features.yml
docker_features:
  security:
    - "GPG key verification"
    - "Secure repository configuration"
    - "User namespace remapping"
    - "No new privileges"
    - "Live restore capability"
  networking:
    - "Bridge netfilter enabled"
    - "IP forwarding controlled"
    - "Default address pools"
    - "Network isolation"
  logging:
    - "JSON log driver"
    - "Log size limits"
    - "Log rotation"
  performance:
    - "Concurrent download limits"
    - "Concurrent upload limits"
    - "File descriptor limits"
```

**Before any changes, verify this inventory is maintained.**

#### **5. Rollback Strategy**

**Always have a rollback plan:**

```yaml
# ✅ Keep backup of working configuration
- name: Backup current configuration
  ansible.builtin.copy:
    src: /etc/docker/daemon.json
    dest: /etc/docker/daemon.json.backup
    remote_src: true
  when: backup_config | default(true)

# ✅ Restore if needed
- name: Restore configuration if fix fails
  ansible.builtin.copy:
    src: /etc/docker/daemon.json.backup
    dest: /etc/docker/daemon.json
  when: restore_needed | default(false)
```

#### **6. Testing Protocol**

**After any debugging, test ALL features:**

```bash
# Test all features after debugging
ansible-playbook playbooks/test_all_features.yml

# Or test individual components
ansible-playbook playbooks/test_security.yml
ansible-playbook playbooks/test_monitoring.yml
ansible-playbook playbooks/test_networking.yml
```

#### **7. Documentation of Changes**

**Document any temporary changes:**

```yaml
# ✅ Document temporary debugging
- name: Temporary debugging - REMOVE AFTER FIX
  ansible.builtin.debug:
    msg: "Temporary: Testing Docker repository"
  when: debug_mode | default(false)
  # TODO: Remove this after fixing GPG key issue
```

#### **8. Code Review Checklist**

**Before committing any debugging changes:**

- [ ] **No features removed** - All existing functionality preserved
- [ ] **Temporary changes marked** - Clearly labeled as temporary
- [ ] **Rollback plan exists** - Can revert if needed
- [ ] **All features tested** - Verified working after fix
- [ ] **Documentation updated** - Changes documented
- [ ] **Security maintained** - All security features intact

#### **9. Common Anti-Patterns to Avoid**

**❌ DON'T DO THESE:**

```yaml
# ❌ Removing security features
- name: Remove Docker security for debugging
  ansible.builtin.file:
    path: /etc/docker/daemon.json
    state: absent

# ❌ Disabling monitoring
- name: Disable monitoring temporarily
  ansible.builtin.service:
    name: monitoring
    state: stopped

# ❌ Removing user permissions
- name: Remove user from docker group
  ansible.builtin.user:
    name: "{{ user }}"
    groups: ""
```

**✅ DO THESE INSTEAD:**

```yaml
# ✅ Add debugging without removing features
- name: Debug with verbose logging
  ansible.builtin.apt:
    name: docker-ce
    state: present
    update_cache: true
  register: docker_install_result

# ✅ Test features after debugging
- name: Verify all features still work
  ansible.builtin.command: docker info
  register: docker_test
```

#### **10. Emergency Procedures**

**If you accidentally remove a feature:**

1. **Immediate rollback** - Use backup or git revert
2. **Document the mistake** - Note what was removed
3. **Restore the feature** - Re-implement immediately
4. **Test thoroughly** - Verify feature works
5. **Update this rule** - Add prevention measures

#### **11. Feature Verification Commands**

**Commands to verify features are preserved:**

```bash
# Verify Docker security
sudo cat /etc/docker/daemon.json | grep -E "(iptables|ip-forward|live-restore)"

# Verify monitoring
sudo systemctl status monitoring

# Verify networking
sudo docker network ls

# Verify logging
sudo ls -la /var/log/docker/

# Verify user permissions
sudo groups $USER | grep docker
```

### **Implementation**

**When debugging any issue:**

1. **First**: Document what you're trying to fix
2. **Second**: Add debugging without removing features
3. **Third**: Fix the specific issue
4. **Fourth**: Test ALL existing features
5. **Fifth**: Remove temporary debugging code
6. **Sixth**: Document the fix

**Remember**: The goal is to **enhance and improve**, never to **remove or devolve**. Every feature we create is valuable and should be preserved.
