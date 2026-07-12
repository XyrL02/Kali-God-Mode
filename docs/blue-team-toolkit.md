# Blue Team Toolkit

## Overview
The Blue Team Toolkit provisions a defensive security / DFIR (Digital Forensics
and Incident Response) environment on a Kali/Debian box. It includes system
hardening, forensics, detection rules, network monitoring, and log analysis tools.

## Tools Installed

### System Hardening & Auditing
| Tool | Purpose | Pre-installed? |
|------|---------|----------------|
| Lynis | Security auditing framework | apt install |
| rkhunter | Rootkit detection | apt install |
| ClamAV | Antivirus scanning | apt install |

### Forensics & Memory Analysis
| Tool | Purpose | Pre-installed? |
|------|---------|----------------|
| Velociraptor | Endpoint visibility & DFIR | GitHub releases |
| volatility3 | Memory forensics framework | pipx |
| bulk_extractor | Disk forensics tool | apt install |

### Detection Rules
| Tool | Purpose | Pre-installed? |
|------|---------|----------------|
| YARA | Pattern matching for malware | apt install |
| YARA rules collection | Community rules | Git clone |

### Network Monitoring
| Tool | Purpose | Pre-installed? |
|------|---------|----------------|
| Zeek | Network security monitor | apt install |
| Suricata | IDS/IPS | apt install |

### Log Analysis
| Tool | Purpose |
|------|---------|
| DeepBlueCLI | PowerShell Windows event log analysis |

## Directory Layout
```
~/Desktop/Kali-God-Mode/blue-team/
├── tools/
│   ├── forensics/               Velociraptor binary
│   ├── detection/               YARA rules collection
│   │   └── yara-rules/          Community YARA rules
│   └── analysis/
│       └── DeepBlueCLI/         PowerShell log analysis
└── tools-info.txt               Tool listing with run commands
```

## Usage

### Install via Kali-God-Mode
```bash
./Kali-God-Mode.sh --blue-team
```

### Lynis (Security Auditing)
```bash
# Full system audit
sudo lynis audit system

# Quick check
sudo lynis audit system --quick

# Check specific profile
sudo lynis audit system --profile /etc/lynis/custom.prf
```

### rkhunter (Rootkit Detection)
```bash
# Update database
sudo rkhunter --update

# Full scan
sudo rkhunter --check

# Check only specific tests
sudo rkhunter --check --skip-keypress --report-warnings-only
```

### ClamAV (Antivirus)
```bash
# Scan a directory
clamscan -r /home/user/

# Scan with removal
clamscan -r --remove /home/user/

# Update signatures
sudo freshclam
```

### Velociraptor
```bash
# Start GUI
velociraptor gui

# Collect artifacts from endpoint
velociraptor collect /path/to/collection

# Query with VQL
velociraptor query "SELECT * FROM processes"
```

### volatility3 (Memory Forensics)
```bash
# List processes
vol -f memory.dump windows.pslist

# Dump a process
vol -f memory.dump windows.memmap --pid 1234 --dump

# Network connections
vol -f memory.dump windows.netscan

# Hashdump
vol -f memory.dump windows.hashdump
```

### YARA
```bash
# Scan with rules
yara rules/malware.yar /path/to/binary

# Scan recursively
yara -r rules/ /path/to/directory/

# With specific rule tag
yara -t malware rules/malware.yar suspicious_file.exe
```

### Zeek (Network Monitoring)
```bash
# Analyze pcap
zeek -r capture.pcap

# Live capture
sudo zeek -i eth0

# With specific scripts
zeek -r capture.pcap frameworks/detect/Malware
```

### Suricata (IDS/IPS)
```bash
# Run against pcap
suricata -c /etc/suricata/suricata.yaml -r capture.pcap

# Live capture
sudo suricata -c /etc/suricata/suricata.yaml -i eth0

# Update rules
sudo suricata-update
```

### DeepBlueCLI (PowerShell Log Analysis)
```powershell
# Import module
Import-Module .\DeepBlue.ps1

# Analyze Windows Security log
Get-WinEventData -LogName Security | .\DeepBlue.ps1

# Analyze from saved evtx
.\DeepBlue.ps1 -LogPath C:\Logs\Security.evtx
```

### Typical Blue Team Workflow
```bash
# 1. Hardening audit
sudo lynis audit system

# 2. Rootkit check
sudo rkhunter --check

# 3. Memory dump analysis
vol -f memory.dump windows.pslist
vol -f memory.dump windows.netscan
vol -f memory.dump windows.hashdump

# 4. Malware scanning
yara -r rules/ /path/to/suspicious/
clamscan -r /home/

# 5. Network traffic analysis
zeek -r suspicious_traffic.pcap
suricata -c /etc/suricata/suricata.yaml -r traffic.pcap

# 6. Log analysis
Get-WinEventData -LogName Security | .\DeepBlue.ps1
```
