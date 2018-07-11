#!/bin/bash

# Installer-Script für das ganze munkiversum
# Danke an die Entwickler von munki-in-a-box (Tom Bridge) und run-munki-run (Graham R Pugh)
# Voraussetzung: mindestens macOS 10.13 Client (kein Server installiert)


# -------------------------------------------------------------
# Variables
# -------------------------------------------------------------

APPNAME="munkiverse_launcher"
LOGGER="/usr/bin/logger -t munkiverse"


# -------------------------------------------------------------
# Make sure the whole script stops if Control-C is pressed.
# -------------------------------------------------------------

fn_terminate() {
    echo "munkiversum_launcher has been terminated."
    exit 1 # SIGINT caught
}
trap 'fn_terminate' SIGINT


# -------------------------------------------------------------
# Functions
# -------------------------------------------------------------

fn_log() { echo "$APPNAME: $@"; /usr/bin/logger -t $APPNAME $@; }
fn_log_ok() { echo "$APPNAME: [OK] $@"; /usr/bin/logger -t $APPNAME [OK] $@;}
fn_log_error() { echo "$APPNAME: [ERROR] $@" 1>&2; /usr/bin/logger -p user.err -t $APPNAME $@;}
fn_versionCheck() {
    # Check that we are meeting the minimum version
		# Thanks Rich Trouton, Tom Bridge, Graham R Pugh
    if [[ $(sw_vers -productVersion | awk -F. '{print $2}') -lt $1 ]]; then
        fn_log_error  "Could not run because the version of the OS does not meet requirements (macOS 10.$1 required)."
        exit 2 # Not met system requirements.
    else
        fn_log_ok  "Mac OS X 10.$(sw_vers -productVersion | awk -F. '{print $2}') or later is installed."
    fi
}
fn_rootCheck() {
    # Check that the script is NOT running as root
		# Thanks Tom Bridge, Graham R Pugh
    if [[ $EUID -eq 0 ]]; then
        fn_log_error "This script is NOT MEANT to run as root. This script is meant to be run as an admin user. I'm going to quit now. Run me without the sudo, please."
        exit 3 # Running as root.
		else
				fn_log_ok "Script is not running as root or with sudo."
    fi
}
fn_adminCheck() {
		# Check that the script is running as an admin user
		if ! id -G $EUID | grep -q -w 80; then
				fn_log_error "User is not an admin user. This script is meant to be run as an admin user. I'm going to quit now."
				exit 4 # User is not an admin.
		else
				fn_log_ok "User seems to be an admin user."
		fi
}
fn_installCommandLineTools() {
    # Installing the Xcode command line tools
    # Thanks Rich Trouton
    cmd_line_tools_temp_file="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
    # Create the placeholder file which is checked by the softwareupdate tool
    # before allowing the installation of the Xcode command line tools.
    touch "$cmd_line_tools_temp_file"
    # Find the last listed update in the Software Update feed with "Command Line Tools" in the name
    cmd_line_tools=$(softwareupdate -l | awk '/\*\ Command Line Tools/ { $1=$1;print }' | tail -1 | sed 's/^[[ \t]]*//;s/[[ \t]]*$//;s/*//' | cut -c 2-)
		#Install the command line tools
    sudo softwareupdate -i "$cmd_line_tools" -v
		# Remove the temp file
    if [[ -f "$cmd_line_tools_temp_file" ]]; then
    		rm "$cmd_line_tools_temp_file"
    fi
		# Check for propper installation
		if [[ -f /Library/Developer/CommandLineTools/usr/bin/gcc ]]; then
				fn_log_ok "Apple Command Line Tools installed"
		else
				fn_log_error "Failed to install Apple Command Line Tools"
				exit 5 # Failed to install Apple Command Line Tools
		fi
}
# git

# munki

# MunkiAdmin

# AutoPkg

# AutoPkgr

# munkireport-php

# Deploystudio

# NetBoot

# Adobe CCP

# syncoverrides.sh


# -------------------------------------------------------------
# Execute functions and others
# -------------------------------------------------------------

echo "Launch to MUNKIVERSE"'!'

fn_versionCheck 13 # check macOS Version; at least 10.[VARIABLE1]
fn_rootCheck # Check that the script is NOT running as root
fn_adminCheck # Check that the script is running as an admin user

fn_installCommandLineTools # Installs Apple Command Line Tools

exit 0
