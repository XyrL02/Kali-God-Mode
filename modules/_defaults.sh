#!/usr/bin/env bash
# =====================================================================
#  Kali-God-Mode — Default Tools
#  Installed on every run. Re-runs skip already-installed tools.
#  Source this file from Kali-God-Mode.sh. Do not run directly.
# =====================================================================

source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

# ---- 1. System update ------------------------------------------------
log "Running apt update && upgrade..."
sudo apt-get update -y 2>&1 | tail -3
sudo apt-get upgrade -y 2>&1 | tail -3

# ---- 2. Base packages -----------------------------------------------
log "Installing base packages..."
apt_get curl wget git unzip tar p7zip-full \
        python3-pip python3-venv pipx jq \
        tor torbrowser-launcher

# Ensure pipx PATH is set
pipx ensurepath >/dev/null 2>&1 || true
export PATH="$HOME/.local/bin:$PATH"

# ---- 3. pimpmykali ---------------------------------------------------
if check_tool pimpmykali; then
    skip_tool "pimpmykali"
else
    log "Installing pimpmykali..."
    if [ -d "$HOME/pimpmykali/.git" ]; then
        warn "pimpmykali already cloned, pulling latest"
        git -C "$HOME/pimpmykali" pull --ff-only 2>/dev/null || true
    else
        git clone https://github.com/Dewalt-arch/pimpmykali.git "$HOME/pimpmykali" 2>/dev/null \
            || warn "pimpmykali clone failed"
    fi
    if [ -d "$HOME/pimpmykali" ]; then
        cd "$HOME/pimpmykali" && sudo bash pimpmykali.sh 2>/dev/null \
            || warn "pimpmykali install had issues (may be fine)"
        cd "$SCRIPT_DIR"
    fi
fi

# ---- 4. Tor Browser --------------------------------------------------
if check_tool torbrowser-launcher; then
    skip_tool "Tor Browser"
else
    log "Installing Tor Browser launcher..."
    apt_get torbrowser-launcher
fi

# Start Tor service
if ! systemctl is-active --quiet tor; then
    log "Starting Tor service..."
    sudo systemctl enable --now tor 2>/dev/null || warn "Could not start Tor service"
else
    info "Tor service already running"
fi

# ---- 5. Tornet (IP rotation) ----------------------------------------
TORNET_VENV="$TOOLKIT_ROOT/default/tornet"
if check_tool tornet && [ -d "$TORNET_VENV" ]; then
    skip_tool "tornet"
else
    log "Installing tornet (IP rotation via Tor)..."
    ensure_dir "$TOOLKIT_ROOT/default"
    python3 -m venv "$TORNET_VENV" 2>/dev/null || warn "tornet venv creation failed"
    if [ -f "$TORNET_VENV/bin/pip" ]; then
        "$TORNET_VENV/bin/pip" install --quiet --upgrade pip 2>/dev/null || true
        "$TORNET_VENV/bin/pip" install --quiet tornet 2>/dev/null \
            || warn "tornet pip install failed"
        # Link tornet to ~/.local/bin so it's on PATH
        ensure_dir "$HOME/.local/bin"
        cat > "$HOME/.local/bin/tornet" << 'TORNET_EOF'
#!/usr/bin/env bash
# Tornet wrapper — activates venv and runs tornet
VENV_DIR="$(dirname "$(readlink -f "$0")")/../Desktop/Kali-God-Mode/default/tornet"
[ -f "$VENV_DIR/bin/activate" ] && source "$VENV_DIR/bin/activate"
exec tornet "$@"
TORNET_EOF
        chmod +x "$HOME/.local/bin/tornet"
        log "tornet installed. Usage:"
        log "  tornet --interval 3 --count 0   (rotate IP every 3s, run forever)"
        log ""
        log "  Firefox proxy config:"
        log "    Settings > Network > Manual proxy > SOCKS Host: 127.0.0.1:9050 (v5)"
        log "    Check: Proxy DNS when using SOCKS v5"
    else
        warn "tornet venv pip not found"
    fi
fi

add_tool_info "$TOOLKIT_ROOT/default" "tornet" "tornet --interval 3 --count 0" "IP rotation via Tor"
add_tool_info "$TOOLKIT_ROOT/default" "pimpmykali" "pimpmykali (already in PATH)" "Kali hardening & tool installer"
add_tool_info "$TOOLKIT_ROOT/default" "Tor Browser" "torbrowser-launcher" "Privacy browser"

log "Default tools setup complete."
