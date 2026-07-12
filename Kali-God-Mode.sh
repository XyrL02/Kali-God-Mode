#!/usr/bin/env bash
# =====================================================================
#  Kali-God-Mode — Master Installer
#
#  A single script to provision a Kali/Debian attack box with
#  engagement-specific toolkits: AD Pentest, Web App Pentest,
#  Red Team, and Blue Team.
#
#  Usage:
#    ./Kali-God-Mode.sh                 # interactive menu
#    ./Kali-God-Mode.sh --all           # install everything
#    ./Kali-God-Mode.sh --ad            # AD pentest only
#    ./Kali-God-Mode.sh --webapp        # web app pentest only
#    ./Kali-God-Mode.sh --red-team      # red team only
#    ./Kali-God-Mode.sh --blue-team     # blue team only
#
#  Re-running is safe: installed tools are detected and skipped.
#
#  NOTE (Windows users): if this file was saved on Windows, strip CRLF
#  before running on Kali:   sed -i 's/\r$//' Kali-God-Mode.sh
# =====================================================================

set -uo pipefail

# ---- Resolve script directory ----------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$SCRIPT_DIR/modules"

# ---- Source shared helpers -------------------------------------------
if [ -f "$MODULES_DIR/_common.sh" ]; then
    source "$MODULES_DIR/_common.sh"
else
    echo "[ERROR] Cannot find modules/_common.sh — run from the repo root."
    exit 1
fi

# ---- Export root path for modules ------------------------------------
export KALI_GOD_MODE_ROOT="${KALI_GOD_MODE_ROOT:-$HOME/Desktop/Kali-God-Mode}"
TOOLKIT_ROOT="$KALI_GOD_MODE_ROOT"

# ---- Ensure base directory -------------------------------------------
ensure_dir "$TOOLKIT_ROOT"
ensure_dir "$TOOLKIT_ROOT/_shared"
ensure_dir "$TOOLKIT_ROOT/_shared/windows"

# ---- Defaults (always installed) -------------------------------------
install_defaults() {
    section "Installing Default Tools"
    source "$MODULES_DIR/_defaults.sh"
}

# ---- Interactive menu ------------------------------------------------
show_menu() {
    echo
    section "Kali-God-Mode — Select Toolkits to Install"
    echo
    echo "  [1] AD Pentest Toolkit"
    echo "      Impacket, BloodHound CE, SharpHound, Kerbrute, Certipy,"
    echo "      Coercer, mitm6, bloodyAD, Ligolo-ng, Armagedon, CVE2PoC, ..."
    echo
    echo "  [2] Web App Pentest Toolkit"
    echo "      ffuf, feroxbuster, wfuzz, dalfox, XSStrike, arjun,"
    echo "      httpx, katana, waybackurls, ..."
    echo
    echo "  [3] Red Team Toolkit"
    echo "      Sliver C2, donut, mimikatz, Rubeus, Ligolo-ng, ..."
    echo
    echo "  [4] Blue Team Toolkit"
    echo "      Velociraptor, YARA, volatility3, Lynis, Zeek, Suricata, ..."
    echo
    echo "  [A] Install ALL toolkits"
    echo "  [Q] Quit (defaults only)"
    echo
    read -rp "  Select toolkits (e.g. 1 2 3 or A): " -a selections
    echo
}

parse_selections() {
    INSTALL_AD=false
    INSTALL_WEBAPP=false
    INSTALL_RED=false
    INSTALL_BLUE=false

    for sel in "${selections[@]}"; do
        case "$sel" in
            1|ad)       INSTALL_AD=true ;;
            2|webapp)   INSTALL_WEBAPP=true ;;
            3|red)      INSTALL_RED=true ;;
            4|blue)     INSTALL_BLUE=true ;;
            A|a|all)    INSTALL_AD=true; INSTALL_WEBAPP=true; INSTALL_RED=true; INSTALL_BLUE=true ;;
            Q|q)        return ;;
            *)          warn "Unknown selection: $sel" ;;
        esac
    done
}

# ---- CLI flag parsing ------------------------------------------------
parse_flags() {
    INSTALL_AD=false
    INSTALL_WEBAPP=false
    INSTALL_RED=false
    INSTALL_BLUE=false

    for flag in "$@"; do
        case "$flag" in
            --all)          INSTALL_AD=true; INSTALL_WEBAPP=true; INSTALL_RED=true; INSTALL_BLUE=true ;;
            --ad)           INSTALL_AD=true ;;
            --webapp)       INSTALL_WEBAPP=true ;;
            --red-team)     INSTALL_RED=true ;;
            --blue-team)    INSTALL_BLUE=true ;;
            -h|--help)
                echo "Usage: $0 [--all|--ad|--webapp|--red-team|--blue-team]"
                echo "       $0   (interactive menu)"
                exit 0
                ;;
            *)              warn "Unknown flag: $flag" ;;
        esac
    done
}

# ---- Main entry point ------------------------------------------------
main() {
    section "Kali-God-Mode v1.0.0"
    info "Toolkits install to: $TOOLKIT_ROOT"
    info "Shared tools:        $TOOLKIT_ROOT/_shared/"

    # Always install defaults first
    install_defaults

    # Determine what to install
    INSTALL_AD=false
    INSTALL_WEBAPP=false
    INSTALL_RED=false
    INSTALL_BLUE=false

    if [ $# -gt 0 ]; then
        # CLI flags mode
        parse_flags "$@"
    else
        # Interactive menu mode
        show_menu
        parse_selections
    fi

    # Run selected modules
    if $INSTALL_AD; then
        section "AD Pentest Toolkit"
        source "$MODULES_DIR/ad-pentest.sh"
    fi

    if $INSTALL_WEBAPP; then
        section "Web App Pentest Toolkit"
        source "$MODULES_DIR/webapp-pentest.sh"
    fi

    if $INSTALL_RED; then
        section "Red Team Toolkit"
        source "$MODULES_DIR/red-team.sh"
    fi

    if $INSTALL_BLUE; then
        section "Blue Team Toolkit"
        source "$MODULES_DIR/blue-team.sh"
    fi

    # Write shared config
    write_config

    # Final summary
    print_summary
}

# ---- Write config.sh (PATH exports) ---------------------------------
write_config() {
    log "Writing config.sh..."
    local config="$TOOLKIT_ROOT/config.sh"
    {
        echo "#!/usr/bin/env bash"
        echo "# Kali-God-Mode — PATH configuration"
        echo "# Source this file: source ~/Desktop/Kali-God-Mode/config.sh"
        echo
        echo "export PATH=\"\$HOME/.local/bin:\$PATH\""
        # Add toolkit script dirs to PATH
        for toolkit_dir in "$TOOLKIT_ROOT"/*/scripts; do
            [ -d "$toolkit_dir" ] && echo "export PATH=\"$toolkit_dir:\$PATH\""
        done
    } > "$config"
    chmod +x "$config"
    info "Config written to: $config"
    info "Run 'source $config' or open a new shell to load PATH."
}

# ---- Print summary ---------------------------------------------------
print_summary() {
    section "Installation Complete"
    echo
    echo -e "  ${GREEN}Toolkits installed to:${RESET}  $TOOLKIT_ROOT"
    echo -e "  ${GREEN}Shared tools:${RESET}           $TOOLKIT_ROOT/_shared/"
    echo -e "  ${GREEN}Config:${RESET}                 $TOOLKIT_ROOT/config.sh"
    echo
    echo -e "  ${YELLOW}Next steps:${RESET}"
    echo "    1. Open a new shell or run:  source $TOOLKIT_ROOT/config.sh"
    echo "    2. Check tool status:        cat $TOOLKIT_ROOT/*/tools-info.txt"
    echo "    3. Check credentials:        cat $TOOLKIT_ROOT/*/creds.txt"
    echo
    echo -e "  ${CYAN}Toolkits:${RESET}"
    $INSTALL_AD     && echo "    ✅ AD Pentest Toolkit"      || echo "    ⬜ AD Pentest Toolkit (skipped)"
    $INSTALL_WEBAPP && echo "    ✅ Web App Pentest Toolkit"  || echo "    ⬜ Web App Pentest Toolkit (skipped)"
    $INSTALL_RED    && echo "    ✅ Red Team Toolkit"         || echo "    ⬜ Red Team Toolkit (skipped)"
    $INSTALL_BLUE   && echo "    ✅ Blue Team Toolkit"        || echo "    ⬜ Blue Team Toolkit (skipped)"
    echo
}

# ---- Run -------------------------------------------------------------
main "$@"
