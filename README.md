# Kali-God-Mode

**One script to install everything.** A modular installer that provisions a
Kali/Debian attack box with engagement-specific toolkits — AD Pentest, Web App
Pentest, Red Team, and Blue Team.

> **Authorized use only.** This installs offensive security tooling. Use it solely on
> systems you own or are explicitly authorized to test (engagements, labs, CTFs).

## Quick Start

```bash
git clone https://github.com/XyrL02/Kali-God-Mode.git
cd Kali-God-Mode
chmod +x Kali-God-Mode.sh
./Kali-God-Mode.sh          # interactive menu — pick your toolkits
```

## Installation Modes

| Command | What happens |
|---------|-------------|
| `./Kali-God-Mode.sh` | Interactive menu — checklist to select toolkits |
| `./Kali-God-Mode.sh --all` | Install everything |
| `./Kali-God-Mode.sh --ad` | AD Pentest Toolkit only |
| `./Kali-God-Mode.sh --webapp` | Web App Pentest Toolkit only |
| `./Kali-God-Mode.sh --red-team` | Red Team Toolkit only |
| `./Kali-God-Mode.sh --blue-team` | Blue Team Toolkit only |

Re-running is safe: installed tools are detected and skipped.

## Default Tools (always installed)

These are installed on every run, regardless of toolkit selection:

| Tool | Purpose |
|------|---------|
| `apt update && upgrade` | System packages |
| pimpmykali | Kali hardening & pre-configured toolset |
| Tor Browser | Privacy browsing |
| tornet | IP address rotation via Tor (SOCKS5 proxy) |

## Toolkit Overview

| Toolkit | Description | Key Tools |
|---------|-------------|-----------|
| **AD Pentest** | Active Directory attack & enumeration | NetExec, BloodHound CE, Kerbrute, Certipy, Armagedon, Ligolo-ng, mimikatz, Rubeus |
| **Web App Pentest** | Web application fuzzing & scanning | ffuf, feroxbuster, dalfox, XSStrike, arjun, katana, nuclei, nikto, sqlmap |
| **Red Team** | Offensive security / C2 | Sliver C2, donut, Ligolo-ng, mimikatz, Rubeus, msfvenom |
| **Blue Team** | Defensive security / DFIR | Velociraptor, YARA, volatility3, Lynis, Zeek, Suricata, ClamAV |

## What Gets Installed Where

```
~/Desktop/Kali-God-Mode/
├── _shared/                         Tools shared across toolkits
│   ├── windows/                     Windows binaries (mimikatz, Rubeus, ...)
│   ├── Ligolo-ng/                   Pivoting proxy
│   ├── kerbrute                     Kerberos brute-forcer
│   └── ...                          Other shared tools
├── ad-pentest/                      AD Pentest Toolkit
│   ├── tools/                       Symlinks to _shared/
│   ├── scripts/                     PATH scripts
│   ├── creds.txt                    BloodHound CE + Neo4j creds
│   └── ...
├── webapp-pentest/                  Web App Pentest Toolkit
│   ├── tools/                       ffuf, dalfox, XSStrike, ...
│   └── tools-info.txt
├── red-team/                        Red Team Toolkit
│   ├── tools/                       Sliver, donut, shared tools
│   └── tools-info.txt
├── blue-team/                       Blue Team Toolkit
│   ├── tools/                       Velociraptor, YARA, volatility3
│   └── tools-info.txt
├── default/                         Default tools (tornet venv)
└── config.sh                        PATH exports — source this after install
```

## Design Principles

1. **No duplication** — tools already in Kali or pimpmykali are skipped (detected via `command -v`)
2. **Shared tools** — common tools (mimikatz, Ligolo-ng, kerbrute) live in `_shared/` and are symlinked by each toolkit
3. **Idempotent** — re-running skips installed tools, only runs updates
4. **Resilient** — a failed download warns and continues, never aborts the script
5. **Organized** — tools grouped by category (pivoting, credentials, fuzzing, etc.)
6. **Documented** — every toolkit has full docs in `docs/`

## Pre-installed Tools (auto-detected, never duplicated)

| Tool | Source |
|------|--------|
| nuclei, nikto, sqlmap, httpx | Pre-installed in Kali |
| msfvenom, responder, netexec | Pre-installed in Kali |
| evil-winrm, crackmapexec, impacket | Pre-installed in Kali |

## Post-Install

```bash
# Load PATH for installed tools
source ~/Desktop/Kali-God-Mode/config.sh

# Check what was installed
cat ~/Desktop/Kali-God-Mode/*/tools-info.txt

# Check credentials
cat ~/Desktop/Kali-God-Mode/ad-pentest/creds.txt
```

## Documentation

Detailed docs for each toolkit:

- [AD Pentest Toolkit](docs/ad-pentest-toolkit.md)
- [Web App Pentest Toolkit](docs/webapp-pentest-toolkit.md)
- [Red Team Toolkit](docs/red-team-toolkit.md)
- [Blue Team Toolkit](docs/blue-team-toolkit.md)

## Project Structure

```
Kali-God-Mode/
├── Kali-God-Mode.sh                # Master installer (entry point)
├── README.md
├── modules/
│   ├── _common.sh                   # Shared helpers
│   ├── _defaults.sh                 # Default tools
│   ├── ad-pentest.sh               # AD pentest module
│   ├── webapp-pentest.sh           # Web app pentest module
│   ├── red-team.sh                 # Red team module
│   └── blue-team.sh                # Blue team module
└── docs/                            # Toolkit documentation
```

## Extending

To add a new toolkit:

1. Create `modules/new-toolkit.sh` (source `_common.sh`)
2. Add install logic using helpers: `dl`, `gh_dl`, `pipx_get`, `apt_get`, `check_tool`, `skip_tool`
3. Add a flag in `Kali-God-Mode.sh` (`--new-toolkit`)
4. Add docs in `docs/new-toolkit.md`
5. Add menu entry in `show_menu()`

## License

MIT
