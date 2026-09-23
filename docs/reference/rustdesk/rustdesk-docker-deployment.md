# RustDesk OSS Server — Docker Deployment Reference

**Platform:** Debian-based Linux / Docker host  
**Deployment:** RustDesk Server OSS (`hbbs` + `hbbr`) using Docker Compose  
**Application data:** `/opt/docker/rustdesk/data`

> This reference assumes Docker Engine and the Docker Compose plugin are already installed and working.

## 1. Architecture

RustDesk Server OSS runs two services:

| Service | Role | Typical Resource Use |
|---|---|---|
| `hbbs` | ID/rendezvous server. Registers clients, coordinates connections, and assists NAT traversal. | Very low |
| `hbbr` | Relay server. Carries session traffic when clients cannot establish a direct peer-to-peer connection. | Very low while idle; network/CPU use increases while relaying |

The default behavior is to **prefer a direct connection** between clients and use `hbbr` only when required.

Do not force relay unless there is a specific reason.

### Normal Direct Connection

    Client A ──► hbbs ◄── Client B
                   │
             connection setup
                   │
    Client A ◄══════════► Client B
           direct connection

### Relay Fallback

If direct connectivity cannot be established:

    Client A ──► hbbr ──► Client B
                 relay

## 2. Verify the Host

Check system architecture and available resources:

    uname -m
    free -h
    df -h

Verify Docker:

    docker --version
    docker compose version

Verify the Docker service:

    systemctl status docker

## 3. Create the Deployment Directory

    sudo mkdir -p /opt/docker/rustdesk/data
    sudo chown -R "$USER":"$USER" /opt/docker/rustdesk
    cd /opt/docker/rustdesk

Directory layout:

    /opt/docker/rustdesk/
    ├── compose.yaml
    └── data/

`data/` contains RustDesk's persistent database and cryptographic key pair.

## 4. Create `compose.yaml`

Create the file:

    vi /opt/docker/rustdesk/compose.yaml

Use:

    # RustDesk Server OSS
    # Documentation:
    # https://rustdesk.com/docs/en/self-host/rustdesk-server-oss/docker/

    services:
      hbbs:
        container_name: rustdesk-hbbs
        image: rustdesk/rustdesk-server:1.1.16
        command: hbbs
        volumes:
          - ./data:/root
        network_mode: "host"
        depends_on:
          - hbbr
        restart: unless-stopped

      hbbr:
        container_name: rustdesk-hbbr
        image: rustdesk/rustdesk-server:1.1.16
        command: hbbr
        volumes:
          - ./data:/root
        network_mode: "host"
        restart: unless-stopped

### Why Host Networking?

`network_mode: "host"` allows RustDesk to bind directly to the Docker host's network interfaces rather than using Docker port mappings.

Because host networking is used, there is **no `ports:` section** in this Compose file.

## 5. Validate the Compose File

    cd /opt/docker/rustdesk
    docker compose config

Fix any reported YAML or configuration errors before continuing.

## 6. Start RustDesk

    docker compose up -d

Docker automatically downloads the image if it is not already present.

Verify:

    docker compose ps

Expected containers:

    rustdesk-hbbs
    rustdesk-hbbr

Check logs:

    docker compose logs

Or individually:

    docker logs rustdesk-hbbs
    docker logs rustdesk-hbbr

## 7. Verify Listening Ports

    sudo ss -lntup | grep 211

Expected RustDesk Server OSS ports include:

| Port | Protocol | Service | Purpose |
|---:|---|---|---|
| `21115` | TCP | `hbbs` | NAT type testing |
| `21116` | TCP/UDP | `hbbs` | ID/rendezvous, heartbeat, and connection coordination |
| `21117` | TCP | `hbbr` | Relay traffic |
| `21118` | TCP | `hbbs` | WebSocket support |
| `21119` | TCP | `hbbr` | WebSocket relay support |

Native RustDesk clients do not normally require WebSocket mode.

Leave **Use WebSocket** disabled on clients unless specifically needed.

## 8. Retrieve the Server Public Key

RustDesk generates its key pair on first startup.

Display **only the public key**:

    cat /opt/docker/rustdesk/data/id_ed25519.pub

Copy the entire value, including any trailing `=` character.

### Important

Do **not** display, publish, commit, or share:

    /opt/docker/rustdesk/data/id_ed25519

That file is the server's **private key**.

The following file is safe to distribute to RustDesk clients:

    /opt/docker/rustdesk/data/id_ed25519.pub

## 9. Configure RustDesk Clients

On each RustDesk client, open:

**Settings → Network → ID/Relay Server**

For a LAN or VPN deployment:

    ID Server:     <SERVER-IP-OR-HOSTNAME>
    Relay Server:  leave blank initially
    API Server:    leave blank
    Key:           <contents of id_ed25519.pub>

Keep **Use WebSocket** disabled unless specifically required.

Each endpoint maintains its own RustDesk authentication settings.

For unattended access, configure a strong permanent password on the endpoint being controlled.

## 10. Direct vs. Relayed Sessions

The desired server behavior is:

    ALWAYS_USE_RELAY=N

This is the normal/default behavior.

RustDesk attempts direct connectivity first and uses `hbbr` only when necessary.

When direct peer-to-peer connectivity succeeds, the server primarily handles connection coordination rather than carrying the remote desktop session traffic.

## 11. Monitor Resource Usage

Check overall host resources:

    free -h
    htop

Monitor the RustDesk containers:

    docker stats rustdesk-hbbs rustdesk-hbbr

During a remote session, watch the `NET I/O` column.

If `rustdesk-hbbr` accumulates substantial network traffic during the session, the connection is likely being relayed.

If `hbbr` remains mostly idle, the clients are likely communicating directly.

Typical behavior:

- `hbbs` should remain extremely lightweight.
- `hbbr` should remain lightweight while idle.
- `hbbr` resource and bandwidth usage increases while actively relaying session traffic.

## 12. Restart / Stop / Start

Restart the services:

    cd /opt/docker/rustdesk
    docker compose restart

Stop and remove the containers while preserving persistent data:

    docker compose down

Start again:

    docker compose up -d

Because `data/` is a bind-mounted directory, `docker compose down` does **not** delete the RustDesk keys or database.

## 13. Updating the Server

The deployment is pinned to:

    rustdesk/rustdesk-server:1.1.16

Using a pinned version provides a reproducible deployment and prevents an unexpected change from a mutable `latest` tag.

For a deliberate upgrade:

1. Review the target RustDesk Server release.
2. Back up `/opt/docker/rustdesk/data/`.
3. Change the image tag in `compose.yaml`.
4. Pull the new image and recreate the containers:

       cd /opt/docker/rustdesk
       docker compose pull
       docker compose up -d

5. Verify:

       docker compose ps
       docker compose logs

## 14. Back Up Persistent State

The important directory is:

    /opt/docker/rustdesk/data/

It contains the server database and identity/key material.

A backup must be stored securely because it includes the **private server key**.

If the Compose configuration is stored in a public Git repository, exclude persistent data.

Example `.gitignore`:

    # RustDesk persistent state and cryptographic keys
    data/

## 15. Generate a Completely New RustDesk Identity

Only do this when intentionally rotating or replacing the server key pair.

    cd /opt/docker/rustdesk
    docker compose down
    rm data/id_ed25519 data/id_ed25519.pub
    docker compose up -d

RustDesk will generate a new key pair.

Retrieve the new public key:

    cat data/id_ed25519.pub

All clients configured with the old public key must then be updated.

## 16. Completely Remove the Deployment

Stop and remove the containers:

    cd /opt/docker/rustdesk
    docker compose down

Remove the deployment directory, including the database and keys:

    cd /opt/docker
    sudo rm -rf /opt/docker/rustdesk

Remove the Docker image if it is no longer needed:

    docker image rm rustdesk/rustdesk-server:1.1.16

Verify removal:

    docker ps -a | grep -i rustdesk
    docker images | grep -i rustdesk
    sudo find /opt/docker -iname '*rustdesk*'

No output indicates that the RustDesk containers, images, and files checked above are gone.

## 17. Security Notes

- Never publish `id_ed25519`.
- `id_ed25519.pub` is the public server key and can be distributed to clients.
- Include the complete public key, including a trailing `=` if present.
- Use a unique strong permanent password on each RustDesk endpoint that requires unattended access.
- Do not expose RustDesk ports to the Internet simply for LAN testing.
- If external access is required, deliberately configure firewall and NAT rules and expose only the required services.
- Keep `ALWAYS_USE_RELAY=N` unless relay-only operation is intentionally required.
- Keep unrelated critical host services independent from the RustDesk Compose stack.
- Back up the RustDesk `data/` directory securely before upgrades or migration.
- Exclude persistent RustDesk data and cryptographic keys from public repositories.

## Quick Verification Checklist

    cd /opt/docker/rustdesk

    docker compose ps
    docker compose logs --tail=50
    sudo ss -lntup | grep 211
    cat data/id_ed25519.pub
    free -h
    docker stats --no-stream rustdesk-hbbs rustdesk-hbbr

A healthy deployment should show:

- Both RustDesk containers running.
- RustDesk listening on its expected ports.
- A generated server public key.
- No significant container errors.
- Adequate available host resources.
- Little or no `hbbr` traffic when clients establish a direct connection.
