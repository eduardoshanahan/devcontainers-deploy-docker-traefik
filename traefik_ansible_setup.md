# Traefik Deployment with Ansible (Best Practices)

This guide shows how to deploy **Traefik** on a VPS using **Ansible** with a dedicated deploy user, without relying on the default `ubuntu` account.

---

## Directory layout on the host

Use one app root and mount into the paths Traefik expects:

```
/opt/traefik/
  traefik.yml          # static config
  dynamic/
    middlewares.yml    # dynamic config (routers/services/middlewares)
  acme/
    acme.json          # cert storage (0600)
  logs/
```

---

## Ansible Playbook Tasks

Run these as your deploy user, but escalate (`become: true`) only where needed.

```yaml
- hosts: vps
  become: true
  vars:
    traefik_user: traefik
    traefik_group: traefik
    traefik_root: /opt/traefik
    traefik_image: traefik:v2.11

  tasks:
    - name: Ensure traefik system group
      group:
        name: "{{ traefik_group }}"
        system: true

    - name: Ensure traefik system user
      user:
        name: "{{ traefik_user }}"
        group: "{{ traefik_group }}"
        system: true
        shell: /usr/sbin/nologin
        create_home: false

    - name: Create Traefik directories
      file:
        path: "{{ traefik_root }}/{{ item }}"
        state: directory
        owner: "{{ traefik_user }}"
        group: "{{ traefik_group }}"
        mode: "0750"
      loop:
        - ""
        - dynamic
        - acme
        - logs

    - name: Create/secure ACME storage
      copy:
        dest: "{{ traefik_root }}/acme/acme.json"
        content: "{}\n"
        owner: "{{ traefik_user }}"
        group: "{{ traefik_group }}"
        mode: "0600"
      force: false

    - name: Install static config
      copy:
        src: files/traefik/traefik.yml
        dest: "{{ traefik_root }}/traefik.yml"
        owner: "{{ traefik_user }}"
        group: "{{ traefik_group }}"
        mode: "0640"

    - name: Install dynamic config
      copy:
        src: files/traefik/middlewares.yml
        dest: "{{ traefik_root }}/dynamic/middlewares.yml"
        owner: "{{ traefik_user }}"
        group: "{{ traefik_group }}"
        mode: "0640"

    - name: Create shared docker network
      community.docker.docker_network:
        name: proxy
        state: present

    - name: Run Traefik
      community.docker.docker_container:
        name: traefik
        image: "{{ traefik_image }}"
        restart_policy: always
        networks:
          - name: proxy
        ports:
          - "80:80"
          - "443:443"
          - "127.0.0.1:8080:8080"
        volumes:
          - "{{ traefik_root }}/traefik.yml:/traefik.yml:ro"
          - "{{ traefik_root }}/dynamic:/dynamic:ro"
          - "{{ traefik_root }}/acme:/acme"
          - "{{ traefik_root }}/logs:/logs"
          - "/var/run/docker.sock:/var/run/docker.sock:ro"
        command: >
          --configFile=/traefik.yml
```

---

## Static config (`traefik.yml`)

```yaml
entryPoints:
  web:
    address: ":80"
  websecure:
    address: ":443"

providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    exposedByDefault: false
  file:
    directory: "/dynamic"
    watch: true

api:
  dashboard: true
  insecure: false

certificatesResolvers:
  letsencrypt:
    acme:
      email: you@example.com
      storage: /acme/acme.json
      httpChallenge:
        entryPoint: web

log:
  level: INFO
  filePath: /logs/traefik.log

accessLog:
  filePath: /logs/access.log
```

---

## Dynamic config example (`middlewares.yml`)

```yaml
http:
  middlewares:
    redirect-to-https:
      redirectScheme:
        scheme: https
        permanent: true
```

---

## Example App Container with Labels

```yaml
- name: Run whoami (test app)
  community.docker.docker_container:
    name: whoami
    image: traefik/whoami
    restart_policy: always
    networks:
      - name: proxy
    labels:
      "traefik.enable": "true"
      "traefik.http.routers.whoami.entrypoints": "web"
      "traefik.http.routers.whoami.rule": "Host(`whoami.example.com`)"
      "traefik.http.middlewares.redirect.redirectscheme.scheme": "https"
      "traefik.http.routers.whoami.middlewares": "redirect@file"
      "traefik.http.routers.whoami-secure.entrypoints": "websecure"
      "traefik.http.routers.whoami-secure.rule": "Host(`whoami.example.com`)"
      "traefik.http.routers.whoami-secure.tls": "true"
      "traefik.http.routers.whoami-secure.tls.certresolver": "letsencrypt"
      "traefik.http.services.whoami.loadbalancer.server.port": "80"
```

---

## Securing docker.sock

By default, the playbook mounts `/var/run/docker.sock`. For more security, run a **docker-socket-proxy** and point Traefik to it:

```yaml
- name: Run docker socket proxy
  community.docker.docker_container:
    name: docker-socket-proxy
    image: tecnativa/docker-socket-proxy:edge
    restart_policy: always
    networks:
      - name: proxy
    environment:
      CONTAINERS: 1
      SERVICES: 1
      TASKS: 1
      NODES: 1
      NETWORKS: 1
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
```

Then set in `traefik.yml`:

```yaml
providers:
  docker:
    endpoint: "tcp://docker-socket-proxy:2375"
    exposedByDefault: false
```

---

## Notes

- `acme.json` **must be 0600**.
- Use Ansible `become: true` for privileged tasks (creating dirs, managing configs).  
- Do not add your deploy user to the `docker` group unless absolutely necessary.
- Expose the dashboard only on `127.0.0.1` or behind auth.

---

## Analysis: Current vs. Proposed Directory Management

### Current Implementation Issues:
1. **Complex directory structure**: Your current setup uses `/opt/traefik/config`, `/opt/traefik/dynamic`, `/opt/traefik/certs`, `/opt/traefik/logs`
2. **Permission complexity**: Multiple permission modes (0755, 0750, 0700) and ownership changes
3. **User management**: Uses existing `docker_deployment` user instead of dedicated system user
4. **Volume mapping complexity**: Maps individual directories to different container paths

### Proposed Guidelines Benefits:
1. **Simplified structure**: `/opt/traefik/` with direct files and subdirectories
2. **Dedicated system user**: `traefik` user with `/usr/sbin/nologin` shell
3. **Consistent permissions**: 0750 for directories, 0600 for `acme.json`
4. **Cleaner volume mapping**: Mount entire `/opt/traefik/` structure into container

## Recommended Changes

Here are the key changes you should implement to align with the team's guidelines:

### 1. **Simplify Directory Structure**
```yaml
# Current (complex):
traefik_base_dir: "/opt/traefik"
traefik_config_dir: "{{ traefik_base_dir }}/config"
traefik_dynamic_dir: "{{ traefik_base_dir }}/dynamic"
traefik_certs_dir: "{{ traefik_base_dir }}/certs"
traefik_logs_dir: "{{ traefik_base_dir }}/logs"

# Proposed (simplified):
traefik_root: "/opt/traefik"
# Files directly in traefik_root:
# - traefik.yml
# - dynamic/middlewares.yml
# - acme/acme.json
# - logs/
```

### 2. **Create Dedicated System User**
```yaml
# Add to your variables:
traefik_user: "traefik"
traefik_group: "traefik"
```

### 3. **Simplify Volume Mapping**
```yaml
# Current (complex mapping):
volumes:
  - "{{ traefik_config_file }}:{{ traefik_container_config_path }}:ro"
  - "{{ traefik_dynamic_config_dir }}:{{ traefik_container_dynamic_path }}:ro"
  - "{{ traefik_certs_dir }}:{{ traefik_container_certs_path }}"
  - "{{ traefik_logs_dir }}:{{ traefik_container_logs_path }}"

# Proposed (simplified):
volumes:
  - "{{ traefik_root }}/traefik.yml:/traefik.yml:ro"
  - "{{ traefik_root }}/dynamic:/dynamic:ro"
  - "{{ traefik_root }}/acme:/acme"
  - "{{ traefik_root }}/logs:/logs"
```

### 4. **Update Configuration Paths**
```yaml
<code_block_to_apply_changes_from>
```

## Implementation Steps

1. **Update your variables** in `src/inventory/group_vars/all/main.yml`
2. **Modify the setup_users_dirs.yml** task to follow the simplified structure
3. **Update deploy_docker.yml** with the new volume mappings
4. **Update your Traefik configuration templates** to use the new paths
5. **Test the deployment** to ensure everything works correctly

Would you like me to help you implement these changes step by step? I can start with updating the variables file and then move on to the task files.

##  **SUMMARY OF FIXES NEEDED:**

### **1. Fix Variable References in Troubleshooting Playbook**
```yaml:src/playbooks/traefik_troubleshooting.yml
# Replace the loop section with correct variable names
loop:
  - "{{ traefik_root }}"
  - "{{ traefik_config_file }}"
  - "{{ traefik_dynamic_config_dir }}"
  - "{{ traefik_root }}/acme"
  - "{{ traefik_log_path }}"
```

### **2. Fix Variable References in Diagnostics Playbook**
```yaml:src/playbooks/traefik_diagnostics.yml
# Replace the loop section with correct variable names
loop:
  - "{{ traefik_config_file }}"
  - "{{ traefik_dynamic_config_dir }}/middlewares.yml"
  - "{{ traefik_root }}/acme/acme.json"
```

### **3. Update Documentation**
Update `traefik_ansible_setup.md` to reflect the current simplified directory structure.

### **4. Keep Useful Files**
- The standalone `traefik_diagnostics.yml` is useful for independent troubleshooting
- The symlink structure is correct and should be kept
- The scripts are compatible and working

The main issues are the variable reference mismatches in the troubleshooting and diagnostic playbooks. Once these are fixed, the project will be fully consistent and maintainable.

##  **IMPLEMENTING ALL FIXES**

### **1. Fix the force: no issue in documentation**

```markdown:traefik_ansible_setup.md
<code_block_to_apply_changes_from>
```

### **2. Fix the troubleshooting playbook to use correct file names**

```yaml:src/playbooks/traefik_troubleshooting.yml
# ... existing code ...

    - name: Check if Traefik dynamic configuration exists
      ansible.builtin.stat:
        path: "{{ traefik_dynamic_config_dir ~ '/middlewares.yml' }}"
      register: traefik_dynamic_config_stat

    - name: Ensure Traefik dynamic configuration exists
      ansible.builtin.file:
        path: "{{ traefik_dynamic_config_dir ~ '/middlewares.yml' }}"
        state: file
        mode: "{{ traefik_config_file_mode }}"
      when: not traefik_dynamic_config_stat.stat.exists

# ... existing code ...
```

### **3. Remove the unused dynamic.yml.j2 template**

The `dynamic.yml.j2` template is not being used and should be removed:

```bash
rm src/roles/deploy_traefik/templates/dynamic.yml.j2
```

### **4. Summary of Files to Keep/Remove**

#### **✅ KEEP (These are useful):**
- `src/playbooks/traefik_health_check.yml` - Useful for monitoring
- `src/playbooks/traefik_diagnostics.yml` - Useful for independent troubleshooting  
- `src/playbooks/traefik_troubleshooting.yml` - Useful for fixing issues
- All scripts in `scripts/` directory - All are functional and useful

#### **️ REMOVE (Orphaned/Unused):**
- `src/roles/deploy_traefik/templates/dynamic.yml.j2` - Not used in current configuration

#### **🔧 FIX (Minor issues):**
- `traefik_ansible_setup.md` - Fix `force: no` → `force: false`
- `src/playbooks/traefik_troubleshooting.yml` - Fix file name references

## 📋 **FINAL CLEANUP SUMMARY:**

1. **✅ Fix documentation syntax** (`force: no` → `force: false`)
2. **✅ Fix troubleshooting playbook** (use `middlewares.yml` instead of `dynamic.yml`)
3. **✅ Remove unused template** (`dynamic.yml.j2`)
4. **✅ Keep all other files** (they are all useful and functional)

After these fixes, the project will be completely clean and consistent!
