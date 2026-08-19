# Scripts

Reusable administration and automation scripts for Windows, macOS, and homelab environments.

Scripts are organized by platform and function. Production-derived scripts are sanitized and generalized before inclusion.

## Structure

```text
scripts/
├── powershell/
│   ├── diagnostics/
│   ├── endpoint-management/
│   └── security/
│
├── bash/
│   ├── diagnostics/
│   └── endpoint-management/
│
├── reference/
│   └── command-snippets.md
│
└── README.md
```

## Categories

| Folder | Purpose |
|---|---|
| `powershell/diagnostics/` | Windows system, network, and performance diagnostics |
| `powershell/endpoint-management/` | Windows configuration, deployment, and maintenance |
| `powershell/security/` | Firewall, security, and remediation utilities |
| `bash/diagnostics/` | macOS/Linux system and network diagnostics |
| `bash/endpoint-management/` | macOS/Linux configuration and deployment |
| `reference/` | Useful administrative commands and short snippets |

## Usage

Scripts are intended for lab, administrative, and educational use. Review and test scripts before running them in another environment.

Environment-specific values, credentials, organization names, and other sensitive information are excluded from the public repository.
