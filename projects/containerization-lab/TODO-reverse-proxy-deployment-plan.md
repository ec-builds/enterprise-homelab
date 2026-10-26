# Reverse Proxy Deployment Plan

**Status:** Planned  
**Type:** Implementation plan / placeholder  
**Lab:** Containerization / Docker Self-Hosted Services

## Overview

Use Nginx Proxy Manager (NPM) to publish HTTP-only web applications through a centralized HTTPS endpoint.

## Planned Work

1. Review existing NPM Docker deployment and record baseline rather than redeploying unnecessarily.
2. Inventory HTTP-only applications and select internal DNS names.
3. Issue an AD CS certificate and upload it to NPM as a custom certificate; document renewal and re-upload/deployment, since NPM does not natively automate AD CS enrollment.
4. Place NPM and local backends on scoped Docker networks; avoid publishing unnecessary HTTP ports.
5. Configure proxy hosts, redirects, access restrictions, and logging.
6. For remote backends, document residual plaintext risk or add backend TLS where feasible.

## Dependencies / Decisions

- AD CS / PKI issuance and trust
- DNS records resolving application hostnames to NPM
- Docker network and firewall design
- Certificate renewal and trust workflow defined in the PKI implementation plan

## Validation / Completion Criteria

- [ ] HTTPS access works with trusted certificates
- [ ] Backend ports are not unintentionally exposed or directly reachable from untrusted networks
- [ ] Custom certificate renewal/replacement procedure documented
- [ ] Proxy requests and errors are observable

## Implementation Notes

> Placeholder: record final architecture, configuration references, test results, screenshots, and lessons learned when implementation begins. Do not mark complete before validation.

**Existing baseline:** NPM already appears in the repository under `configs/docker/nginx-proxy-manager/` and `projects/docker-self-hosted-services/reverse-proxy.md`. This plan covers security integration and refinement, not an assumed greenfield deployment.
