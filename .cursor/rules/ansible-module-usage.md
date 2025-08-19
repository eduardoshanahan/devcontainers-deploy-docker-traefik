# Ansible Module Usage Rules

## Use Proper Ansible Modules Instead of Shell Commands

### **NEVER Use Shell Commands for Package Management**

**❌ WRONG - Don't do this:**

```yaml
- name: Update apt cache
  ansible.builtin.command: apt-get update
  become: true

- name: Install package
  ansible.builtin.command: apt-get install -y package-name
  become: true

- name: Clean apt cache
  ansible.builtin.command: apt-get clean
  become: true
```

**✅ CORRECT - Do this instead:**

```yaml
- name: Update apt cache
  ansible.builtin.apt:
    update_cache: true
  become: true

- name: Install package
  ansible.builtin.apt:
    name: package-name
    state: present
    update_cache: true
  become: true

- name: Clean apt cache
  ansible.builtin.apt:
    update_cache: true
    cache_valid_time: 0
  become: true
```

### **Package Management Module Mapping**

| Shell Command | Proper Ansible Module |
|---------------|----------------------|
| `apt-get update` | `ansible.builtin.apt: update_cache: true` |
| `apt-get install package` | `ansible.builtin.apt: name: package, state: present` |
| `apt-get remove package` | `ansible.builtin.apt: name: package, state: absent` |
| `apt-get clean` | `ansible.builtin.apt: update_cache: true, cache_valid_time: 0` |
| `apt-get autoremove` | `ansible.builtin.apt: autoremove: true` |
| `apt-get upgrade` | `ansible.builtin.apt: upgrade: yes` |

### **File Operations Module Mapping**

| Shell Command | Proper Ansible Module |
|---------------|----------------------|
| `mkdir -p /path` | `ansible.builtin.file: path: /path, state: directory` |
| `chmod 755 file` | `ansible.builtin.file: path: file, mode: "0755"` |
| `chown user:group file` | `ansible.builtin.file: path: file, owner: user, group: group` |
| `rm -rf /path` | `ansible.builtin.file: path: /path, state: absent` |
| `cp src dest` | `ansible.builtin.copy: src: src, dest: dest` |

### **Service Management Module Mapping**

| Shell Command | Proper Ansible Module |
|---------------|----------------------|
| `systemctl start service` | `ansible.builtin.service: name: service, state: started` |
| `systemctl stop service` | `ansible.builtin.service: name: service, state: stopped` |
| `systemctl restart service` | `ansible.builtin.service: name: service, state: restarted` |
| `systemctl enable service` | `ansible.builtin.service: name: service, enabled: true` |

### **User/Group Management Module Mapping**

| Shell Command | Proper Ansible Module |
|---------------|----------------------|
| `useradd username` | `ansible.builtin.user: name: username, state: present` |
| `usermod -a -G group user` | `ansible.builtin.user: name: user, groups: group, append: true` |
| `groupadd groupname` | `ansible.builtin.group: name: groupname, state: present` |

### **Network Configuration Module Mapping**

| Shell Command | Proper Ansible Module |
|---------------|----------------------|
| `sysctl -w net.ipv4.ip_forward=1` | `ansible.posix.sysctl: name: net.ipv4.ip_forward, value: "1"` |
| `iptables -A INPUT -p tcp --dport 22 -j ACCEPT` | Use `ansible.builtin.iptables` or `ansible.builtin.ufw` |

### **When Shell Commands Are Acceptable**

**✅ Use shell commands ONLY for:**

- Complex one-liners that don't have Ansible modules
- Commands that need specific shell features
- Third-party tools without Ansible modules
- Testing and debugging commands

**Example of acceptable shell command:**

```yaml
- name: Test Docker is working
  ansible.builtin.command: docker info
  register: docker_info
  changed_when: false
```

### **Code Review Checklist**

Before committing any Ansible code, verify:

- [ ] **No `apt-get` commands** - Use `ansible.builtin.apt` instead
- [ ] **No `systemctl` commands** - Use `ansible.builtin.service` instead
- [ ] **No `mkdir/chmod/chown`** - Use `ansible.builtin.file` instead
- [ ] **No `useradd/groupadd`** - Use `ansible.builtin.user/group` instead
- [ ] **No `sysctl` commands** - Use `ansible.posix.sysctl` instead

### **Common Patterns to Replace**

**Replace this:**

```yaml
- name: Install packages
  ansible.builtin.command: apt-get install -y package1 package2
  become: true
```

**With this:**

```yaml
- name: Install packages
  ansible.builtin.apt:
    name:
      - package1
      - package2
    state: present
    update_cache: true
  become: true
```

### **Benefits of Using Proper Modules**

1. **Idempotency** - Modules check current state before making changes
2. **Better error handling** - Modules provide detailed error messages
3. **Linter compliance** - No more linter warnings
4. **Cross-platform compatibility** - Modules work on different systems
5. **Better performance** - Modules are optimized for their specific tasks
6. **Consistency** - Standardized way to handle common operations

### **Implementation**

**When writing or editing Ansible code:**

1. **Always check** if there's a proper Ansible module for the task
2. **Use the module mapping table** above for common operations
3. **Avoid shell commands** for basic system operations
4. **Test the module** to ensure it works as expected
5. **Document any exceptions** where shell commands are necessary

This rule ensures consistent, maintainable, and linter-compliant Ansible code.
