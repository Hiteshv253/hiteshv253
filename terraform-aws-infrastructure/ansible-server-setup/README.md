# Ansible Server Setup & Security Hardening

This playbook automates host machine provisioning, security configurations, and container-engine installations.

## 🧬 Playbook Structure

The tasks inside `playbook.yml` manage host servers sequentially:
1. **Administrative Packages**: Installs standard packages (`curl`, `ufw`, `fail2ban`, and `unattended-upgrades` to automatically install security updates).
2. **Security Hardening**:
   - Limits ingress access via **UFW** to ports `22` (SSH), `80` (HTTP), and `443` (HTTPS).
   - Hardens **SSHD** settings: Disables root logins and restricts authentication to SSH Key pairs only.
   - Restarts SSH services dynamically via handlers on config changes.
3. **Docker Engine Setup**: Imports Docker GPG key, installs stable engines, and enables the systemd service.

---

## 🚀 Execution Steps

1. Create a hosts inventory file (`hosts.ini`):
   ```ini
   [webservers]
   192.168.1.100 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa
   ```
2. Validate inventory configurations:
   ```bash
   ansible webservers -i hosts.ini -m ping
   ```
3. Execute provisioning playbooks:
   ```bash
   ansible-playbook -i hosts.ini playbook.yml
   ```
