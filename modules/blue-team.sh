#!/usr/bin/env bash
# =====================================================================
#  Kali-God-Mode — Blue Team Toolkit Module
#  Defensive security / blue team / DFIR tools.
#  Source this file from Kali-God-Mode.sh. Do not run directly.
# =====================================================================

source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

BLUE_DIR="$TOOLKIT_ROOT/blue-team"
BLUE_TOOLS="$BLUE_DIR/tools"

ensure_dir "$BLUE_DIR" "$BLUE_TOOLS"

# =====================================================================
# SECTION 1: System hardening & auditing
# =====================================================================
log "Installing system hardening tools..."

# Lynis (security auditing)
if check_tool lynis; then
    skip_tool "Lynis"
else
    log "Installing Lynis..."
    apt_get lynis
fi

# rkhunter (rootkit detection)
if check_tool rkhunter; then
    skip_tool "rkhunter"
else
    log "Installing rkhunter..."
    apt_get rkhunter
fi

# ClamAV (antivirus)
if check_tool clamscan; then
    skip_tool "ClamAV"
else
    log "Installing ClamAV..."
    apt_get clamav clamav-daemon
    sudo freshclam 2>/dev/null || warn "ClamAV signature update failed"
fi

# =====================================================================
# SECTION 2: Forensics & memory analysis
# =====================================================================
log "Installing forensics tools..."

# Velociraptor (endpoint visibility & DFIR)
if check_tool velociraptor; then
    skip_tool "Velociraptor"
else
    log "Installing Velociraptor..."
    gh_dl Velocidex/velociraptor 'velociraptor.*linux.*amd64' "$BLUE_TOOLS/forensics/velociraptor" 2>/dev/null \
        && chmod +x "$BLUE_TOOLS/forensics/velociraptor" \
        && ensure_dir "$HOME/.local/bin" \
        && ln -sf "$BLUE_TOOLS/forensics/velociraptor" "$HOME/.local/bin/velociraptor" 2>/dev/null \
        || warn "Velociraptor install failed"
fi

# volatility3 (memory forensics)
if check_tool vol; then
    skip_tool "volatility3"
else
    log "Installing volatility3..."
    pipx_get "git+https://github.com/volatilityfoundation/volatility3" "vol"
fi

# bulk_extractor (disk forensics)
if check_tool bulk_extractor; then
    skip_tool "bulk_extractor"
else
    log "Installing bulk_extractor..."
    apt_get bulk-extractor
fi

# =====================================================================
# SECTION 3: Detection rules & YARA
# =====================================================================
log "Installing detection tools..."

# YARA
if check_tool yara; then
    skip_tool "YARA"
else
    log "Installing YARA..."
    apt_get yara
fi

# YARA rules collection (from official repo)
if [ -d "$BLUE_TOOLS/detection/yara-rules/.git" ]; then
    info "YARA rules already cloned"
else
    log "Downloading YARA rules collection..."
    ensure_dir "$BLUE_TOOLS/detection"
    git clone https://github.com/Yara-Rules/rules.git "$BLUE_TOOLS/detection/yara-rules" 2>/dev/null \
        || warn "YARA rules clone failed"
fi

# =====================================================================
# SECTION 4: Network monitoring & analysis
# =====================================================================
log "Installing network monitoring tools..."

# Zeek (network security monitor)
if check_tool zeek; then
    skip_tool "Zeek"
else
    log "Installing Zeek..."
    apt_get zeek || warn "Zeek install failed (may need manual setup)"
fi

# Suricata (IDS/IPS)
if check_tool suricata; then
    skip_tool "Suricata"
else
    log "Installing Suricata..."
    apt_get suricata
    # Download ET Open rules
    if command -v suricata-update &>/dev/null; then
        sudo suricata-update 2>/dev/null || warn "Suricata rules update failed"
    fi
fi

# =====================================================================
# SECTION 5: Log analysis & OSINT
# =====================================================================
log "Installing analysis tools..."

# DeepBlueCLI (PowerShell log analysis)
if [ -f "$BLUE_TOOLS/analysis/DeepBlueCLI/DeepBlue.ps1" ]; then
    info "DeepBlueCLI already downloaded"
else
    log "Downloading DeepBlueCLI..."
    ensure_dir "$BLUE_TOOLS/analysis/DeepBlueCLI"
    dl https://raw.githubusercontent.com/sans-blue-team/DeepBlueCLI/master/DeepBlue.ps1 \
       "$BLUE_TOOLS/analysis/DeepBlueCLI/DeepBlue.ps1" 2>/dev/null \
        || warn "DeepBlueCLI download failed"
fi

# =====================================================================
# SECTION 6: tools-info.txt
# =====================================================================
add_tool_info "$BLUE_DIR" "Lynis" "lynis audit system" "Security auditing"
add_tool_info "$BLUE_DIR" "rkhunter" "sudo rkhunter --check" "Rootkit detection"
add_tool_info "$BLUE_DIR" "ClamAV" "clamscan -r /path" "Antivirus scanning"
add_tool_info "$BLUE_DIR" "Velociraptor" "velociraptor gui" "Endpoint visibility & DFIR"
add_tool_info "$BLUE_DIR" "volatility3" "vol -f memory.dump" "Memory forensics"
add_tool_info "$BLUE_DIR" "bulk_extractor" "bulk_extractor -o output input.e01" "Disk forensics"
add_tool_info "$BLUE_DIR" "YARA" "yara rules/malware.yar target" "Pattern matching"
add_tool_info "$BLUE_DIR" "Zeek" "zeek -i eth0" "Network security monitor"
add_tool_info "$BLUE_DIR" "Suricata" "sudo suricata -c /etc/suricata/suricata.yaml -i eth0" "IDS/IPS"
add_tool_info "$BLUE_DIR" "DeepBlueCLI" "Import-Module .\\DeepBlue.ps1; Get-WinEventData -LogName Security | .\\DeepBlue.ps1" "PowerShell log analysis"

# =====================================================================
# Done
# =====================================================================
log "Blue Team Toolkit setup complete."
info "Tools: $BLUE_DIR"
