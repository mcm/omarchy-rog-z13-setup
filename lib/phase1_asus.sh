#!/bin/bash
# Phase 1: ASUS Tools (G14 repo, asusctl, rog-control-center)
#
# This branch stays on Omarchy's own kernel (linux-omarchy, the default since
# Omarchy 4.0.4) instead of switching to linux-cachyos. That drops the CachyOS
# repos and the pacman.conf juggling that was needed to reinstall Hyprland from
# stable repos around them. A CachyOS kernel installed by an older run of this
# script is left alone; remove it yourself if you no longer want it.

phase1_check() {
    file_contains /etc/pacman.conf "[g14]" \
        && is_pkg_installed asusctl
}

phase1_run() {
    if is_pkg_installed linux-cachyos; then
        warn "linux-cachyos is installed from an earlier run. This branch no longer manages it;"
        warn "it stays a boot option until you remove it (and the [cachyos*] repos) yourself."
    fi

    # Add G14 repo and install ASUS tools if not present
    if ! file_contains /etc/pacman.conf "[g14]"; then
        local backup
        backup="/etc/pacman.conf.bak.rog-z13.$(date +%s)"
        run_sudo cp /etc/pacman.conf "$backup"
        info "Backed up pacman.conf to $backup"

        info "Adding G14 repository..."
        run_sudo_tee /etc/pacman.conf "\n[g14]\nServer = https://arch.asus-linux.org"
        run_sudo pacman-key --recv-keys 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35
        run_sudo pacman-key --lsign-key 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35
        success "G14 repo added and keys imported."
    else
        success "G14 repo already present."
    fi

    if ! is_pkg_installed asusctl; then
        info "Installing asusctl and rog-control-center..."
        run_sudo pacman -Sy --noconfirm asusctl rog-control-center
        success "ASUS tools installed."
    else
        success "ASUS tools already installed."
    fi
}
