# Feature Preservation Rules

## Never Remove Existing Features During Debugging

### **Core Principle: Add, Don't Subtract**

When debugging or fixing issues, **NEVER remove existing features** that were intentionally created. The goal is to **improve and enhance**, not **devolve or remove**.

### **Debugging Process Rules**

#### **1. Temporary Changes Only**

```yaml
# PASS - Temporary debugging
- name: Debug Docker installation
  ansible.builtin.debug:
    msg: "Testing Docker GPG key"
  when: debug_mode | default(false)

# FAIL - Removing features
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

##### **Step 1: Identify the Issue**

```bash
# Don't remove features, add debugging
- name: Debug the specific issue
  ansible.builtin.debug:
    msg: "Current configuration: {{ item }}"
  loop: "{{ current_config }}"
```

##### **Step 2: Add Temporary Debugging**

```yaml
# PASS - Add debugging without removing features
- name: Debug Docker GPG key
  ansible.builtin.command: ls -la /etc/apt/keyrings/
  register: debug_gpg
  changed_when: false

- name: Show debug info
  ansible.builtin.debug:
    msg: "{{ debug_gpg.stdout }}"
```

##### **Step 3: Fix the Issue**

```yaml
# PASS - Fix the issue while preserving all features
- name: Fix GPG key issue
  ansible.builtin.get_url:
    url: https://download.docker.com/linux/ubuntu/gpg
    dest: /etc/apt/keyrings/docker.gpg
    mode: "0644"
  # Keep all existing security configurations
```

##### **Step 4: Verify All Features Still Work**

```yaml
# PASS - Test that all features are preserved
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
```

## **12. Final Check for Remaining Emoji Violations**
