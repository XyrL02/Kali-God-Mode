#!/usr/bin/env bash
# =====================================================================
#  Kali-God-Mode — Red Team Toolkit Module
#  Offensive security / red team engagement tools.
#  Source this file from Kali-God-Mode.sh. Do not run directly.
#
#  Pre-installed in Kali (SKIPPED): msfvenom, responder, netexec,
#  evil-winrm, metasploit, crackmapexec
#
#  Shared tools from _shared/: kerbrute, Ligolo-ng, mimikatz,
#  Rubeus, Certify, nc64, php_reverse_shell
# =====================================================================

source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

RED_DIR="$TOOLKIT_ROOT/red-team"
RED_TOOLS="$RED_DIR/tools"
SHARED_WIN="$SHARED_DIR/windows"

ensure_dir "$RED_DIR" "$RED_TOOLS"

# =====================================================================
# SECTION 1: C2 Framework — Sliver
# =====================================================================
log "Installing Sliver C2..."
if check_tool sliver; then
    skip_tool "Sliver"
else
    log "Downloading Sliver (latest release)..."
    SLIVER_DIR="$RED_TOOLS/c2"
    ensure_dir "$SLIVER_DIR"

    # Try GitHub releases
    if gh_dl BishopFox/sliver 'linux.*server' "$SLIVER_DIR/sliver-server" 2>/dev/null; then
        chmod +x "$SLIVER_DIR/sliver-server"

        # Also grab the client
        gh_dl BishopFox/sliver 'linux.*client' "$SLIVER_DIR/sliver" 2>/dev/null \
            && chmod +x "$SLIVER_DIR/sliver"

        # Symlink to PATH
        ensure_dir "$HOME/.local/bin"
        ln -sf "$SLIVER_DIR/sliver-server" "$HOME/.local/bin/sliver-server" 2>/dev/null
        [ -f "$SLIVER_DIR/sliver" ] && ln -sf "$SLIVER_DIR/sliver" "$HOME/.local/bin/sliver" 2>/dev/null

        log "Sliver installed. First run: sliver-server (generates config)"
    else
        warn "Sliver release download failed"
        warn "Manual install: curl -sL https://Sliver.sh/install | sudo bash"
    fi
fi

# =====================================================================
# SECTION 2: Initial Access / Payload generation
# =====================================================================
log "Installing initial access tools..."

# donut (shellcode generator)
if check_tool donut; then
    skip_tool "donut"
else
    log "Installing donut..."
    pipx_get "git+https://github.com/TheWover/donut" "donut"
fi

# msfvenom is pre-installed — skip
skip_tool "msfvenom (pre-installed)"

# =====================================================================
# SECTION 3: Shared tools (symlink from _shared/)
# =====================================================================
log "Linking shared tools for Red Team..."

# Ensure shared tools exist first (in case AD toolkit wasn't installed)
if [ ! -d "$SHARED_DIR/Ligolo-ng" ]; then
    log "Ligolo-ng not found in _shared — downloading..."
    ensure_dir "$SHARED_DIR/Ligolo-ng"
    dl https://github.com/nicocha30/ligolo-ng/releases/download/v0.8.2/ligolo-ng_proxy_0.8.2_linux_amd64.tar.gz /tmp/ligolo-proxy.tar.gz 2>/dev/null \
        && tar -xf /tmp/ligolo-proxy.tar.gz -C "$SHARED_DIR/Ligolo-ng" 2>/dev/null && rm -f /tmp/ligolo-proxy.tar.gz
    dl https://github.com/nicocha30/ligolo-ng/releases/download/v0.8.2/ligolo-ng_agent_0.8.2_windows_amd64.zip /tmp/ligolo-agent.zip 2>/dev/null \
        && unzip -o /tmp/ligolo-agent.zip -d "$SHARED_DIR/Ligolo-ng" >/dev/null 2>&1 && rm -f /tmp/ligolo-agent.zip
fi

if [ ! -f "$SHARED_DIR/kerbrute" ]; then
    log "Kerbrute not found in _shared — downloading..."
    dl https://github.com/ropnop/kerbrute/releases/latest/download/kerbrute_linux_amd64 "$SHARED_DIR/kerbrute" 2>/dev/null \
        && chmod +x "$SHARED_DIR/kerbrute"
fi

# Download missing Windows binaries if AD toolkit wasn't installed
GHOST="https://github.com/r3motecontrol/Ghostpack-CompiledBinaries/raw/master"
for bin in Rubeus.exe Certify.exe; do
    [ -f "$SHARED_WIN/$bin" ] || dl "$GHOST/$bin" "$SHARED_WIN/$bin" 2>/dev/null
done
[ -f "$SHARED_WIN/mimikatz.exe" ] || \
    dl https://raw.githubusercontent.com/ParrotSec/mimikatz/master/x64/mimikatz.exe "$SHARED_WIN/mimikatz.exe" 2>/dev/null
[ -f "$SHARED_WIN/nc64.exe" ] || \
    dl https://github.com/int0x33/nc.exe/raw/refs/heads/master/nc64.exe "$SHARED_WIN/nc64.exe" 2>/dev/null
[ -f "$SHARED_WIN/php_reverse_shell.php" ] || \
    dl https://raw.githubusercontent.com/ivan-sincek/php-reverse-shell/refs/heads/master/src/reverse/php_reverse_shell.php "$SHARED_WIN/php_reverse_shell.php" 2>/dev/null

# Create symlinks
link_tool "$SHARED_DIR/Ligolo-ng"     "$RED_TOOLS/pivoting"
link_tool "$SHARED_WIN"               "$RED_TOOLS/post-exploit"
link_tool "$SHARED_DIR/kerbrute"      "$RED_TOOLS/kerbrute"

# =====================================================================
# SECTION 4: Webshells collection
# =====================================================================
log "Collecting webshells..."
SHELLS_DIR="$RED_TOOLS/webshells"
ensure_dir "$SHELLS_DIR"

# PHP reverse shell (copy to webshells too)
[ -f "$SHARED_WIN/php_reverse_shell.php" ] && \
    cp "$SHARED_WIN/php_reverse_shell.php" "$SHELLS_DIR/" 2>/dev/null

# =====================================================================
# SECTION 5: tools-info.txt
# =====================================================================
add_tool_info "$RED_DIR" "Sliver C2" "sliver-server" "C2 framework"
add_tool_info "$RED_DIR" "donut" "donut" "Shellcode generator"
add_tool_info "$RED_DIR" "Kerbrute" "$SHARED_DIR/kerbrute" "User enum + password spray"
add_tool_info "$RED_DIR" "Ligolo-ng" "$SHARED_DIR/Ligolo-ng/ligolo-ng_proxy" "Pivoting proxy"
add_tool_info "$RED_DIR" "msfvenom" "(pre-installed)" "Payload generator"
add_tool_info "$RED_DIR" "Responder" "(pre-installed)" "LLMNR/NBT-NS poisoning"
add_tool_info "$RED_DIR" "netexec" "(pre-installed)" "SMB/AD enumeration"
add_tool_info "$RED_DIR" "evil-winrm" "(pre-installed)" "WinRM shell"
add_tool_info "$RED_DIR" "mimikatz.exe" "$SHARED_WIN/mimikatz.exe" "Credential dump (Windows)"
add_tool_info "$RED_DIR" "Rubeus.exe" "$SHARED_WIN/Rubeus.exe" "Kerberos abuse (Windows)"
add_tool_info "$RED_DIR" "Certify.exe" "$SHARED_WIN/Certify.exe" "ADCS attacks (Windows)"

# =====================================================================
# Done
# =====================================================================
log "Red Team Toolkit setup complete."
info "Tools:      $RED_DIR"
info "Shared:     $SHARED_DIR"
