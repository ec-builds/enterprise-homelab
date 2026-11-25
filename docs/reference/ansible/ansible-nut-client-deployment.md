# Ansible NUT Client Deployment

Reference guide for deploying the Network UPS Tools (NUT) client to the Proxmox nodes with Ansible, so each node shuts down cleanly when the NUT server forces a shutdown or the UPS reports low battery. Clients run no timers: the commit timer lives on the server (see [NUT Shutdown Sequence and Testing](../nut/nut-shutdown-and-testing.md)). The manual equivalent is [NUT Client Setup](../nut/nut-client-setup.md).

The NUT server runs on `monitor-lab-02` (see [NUT Server Installation](../nut/nut-server-installation.md)). This project configures the clients. Plan: [Ansible NUT Client Deployment](../../../projects/infrastructure-automation/TODO-ansible-nut-clients.md).

> [!NOTE]
> This project is planned and hasn't been run yet. Examples follow standard Ansible and Debian NUT layouts and are updated after the first deployment.

## Overview

| Setting | Value |
|---|---|
| **Control node** | Admin workstation |
| **Managed hosts** | `prox-lab-01`, `prox-lab-02`, `prox-lab-03` |
| **Connection** | SSH as `adminuser` with an SSH key, `become` for root tasks |
| **Package** | `nut-client` |
| **NUT mode** | `netclient` |
| **NUT server** | `monitor-lab-02`, UPS `ups`, user `upsmon_remote` (`secondary`) |
| **Secrets** | Ansible Vault |

```text
Admin workstation
  ansible-playbook nut-clients.yml
        │ SSH
        ├──► prox-lab-01 ─┐
        ├──► prox-lab-02 ─┼── upsmon ──► upsd on monitor-lab-02 (3493/TCP)
        └──► prox-lab-03 ─┘
                │
                ▼
     Forced shutdown from the server, or low battery
     → shutdown (VMs stop with the host)
```

## Project Layout

```text
ansible/
├── ansible.cfg
├── inventories/
│   └── lab/
│       ├── hosts.ini
│       └── group_vars/
│           └── proxmox/
│               ├── vars.yml
│               └── vault.yml          # encrypted with Ansible Vault
├── playbooks/
│   └── nut-clients.yml
└── roles/
    └── nut_client/
        ├── defaults/main.yml
        ├── handlers/main.yml
        ├── tasks/main.yml
        └── templates/
            ├── nut.conf.j2
            └── upsmon.conf.j2
```

## 1. Install Ansible on the Control Node

macOS:

```bash
brew install ansible
```

Debian:

```bash
sudo apt install ansible
```

Check:

```bash
ansible --version
```

## 2. Inventory

`inventories/lab/hosts.ini`:

```ini
[proxmox]
prox-lab-01 ansible_host=10.0.0.20
prox-lab-02 ansible_host=10.0.0.21
prox-lab-03 ansible_host=10.0.0.22

[proxmox:vars]
ansible_user=adminuser
```

`ansible.cfg`:

```ini
[defaults]
inventory = inventories/lab/hosts.ini
roles_path = roles
host_key_checking = True
```

Test the connection:

```bash
ansible proxmox -m ping
```

## 3. Variables and Vault

`inventories/lab/group_vars/proxmox/vars.yml`:

```yaml
nut_server: <nut-server-ip>   # IP, not hostname: DNS may be down during an outage
nut_ups_name: ups
nut_user: upsmon_remote
nut_password: "{{ vault_nut_password }}"
```

Create the encrypted vault file:

```bash
ansible-vault create inventories/lab/group_vars/proxmox/vault.yml
```

Contents:

```yaml
vault_nut_password: "<upsmon_remote-password>"
```

Only the encrypted file is committed. The vault password itself stays outside the repository.

## 4. Role

`roles/nut_client/defaults/main.yml`:

```yaml
nut_ups_name: ups
```

`roles/nut_client/tasks/main.yml`:

```yaml
- name: Install NUT client
  ansible.builtin.apt:
    name: nut-client
    state: present
    update_cache: true

- name: Set NUT mode
  ansible.builtin.template:
    src: nut.conf.j2
    dest: /etc/nut/nut.conf
    owner: root
    group: nut
    mode: "0640"
  notify: Restart nut-monitor

- name: Configure upsmon
  ansible.builtin.template:
    src: upsmon.conf.j2
    dest: /etc/nut/upsmon.conf
    owner: root
    group: nut
    mode: "0640"
  notify: Restart nut-monitor

- name: Enable and start nut-monitor
  ansible.builtin.service:
    name: nut-monitor
    state: started
    enabled: true
```

`roles/nut_client/handlers/main.yml`:

```yaml
- name: Restart nut-monitor
  ansible.builtin.service:
    name: nut-monitor
    state: restarted
```

### Templates

`nut.conf.j2`:

```ini
MODE=netclient
```

`upsmon.conf.j2`:

```ini
MONITOR {{ nut_ups_name }}@{{ nut_server }} 1 {{ nut_user }} {{ nut_password }} secondary
SHUTDOWNCMD "/sbin/shutdown -h +0"
```

The template replaces Debian's long default `upsmon.conf` with just the settings the client needs; the other defaults are built into `upsmon`.

## 5. Playbook

`playbooks/nut-clients.yml`:

```yaml
- name: Deploy NUT clients to Proxmox nodes
  hosts: proxmox
  become: true
  roles:
    - nut_client
```

## 6. Run

Check mode first, showing what would change:

```bash
ansible-playbook playbooks/nut-clients.yml --ask-vault-pass --check --diff
```

One node first:

```bash
ansible-playbook playbooks/nut-clients.yml --ask-vault-pass --limit prox-lab-01
```

Then all three:

```bash
ansible-playbook playbooks/nut-clients.yml --ask-vault-pass
```

Run it again. A second run should report `changed=0` for every host.

## 7. Verify

```bash
ansible proxmox -b -a "upsc ups@<nut-server-ip> ups.status"
ansible proxmox -b -a "systemctl is-active nut-monitor"
```

Expected: `OL` and `active` on all three nodes.

On the NUT server, `upsc -c ups@localhost` should list all three nodes. Shutdown behavior itself is tested from the server: see [NUT Shutdown Sequence and Testing](../nut/nut-shutdown-and-testing.md#tests).

## Adding a Host

Add it to the `proxmox` group, or a new group that uses the same role, and run the playbook with `--limit <host>`.

## Troubleshooting

| Symptom | Check |
|---|---|
| `ansible -m ping` fails | SSH key, `ansible_user`, host key in `known_hosts` |
| Vault error | `--ask-vault-pass` given, and the right vault password |
| `upsc` fails from a node | NUT server reachable on `3493/TCP`, `LISTEN` in `upsd.conf`, firewall |
| `nut-monitor` logs a login failure | `nut_user` and vault password match `upsd.users` on the server |
| Node not listed on the server | `nut-monitor` active on the node, and the node's address allowed by the server firewall |

## Security

- Keep the vault file encrypted and the vault password outside the repository.
- Template files with passwords are `root:nut` and `0640`.
- Use `--diff` with care: it can print templated values, including the NUT password, to the terminal.
