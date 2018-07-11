#!/bin/bash

# Installer-Script für das ganze munkiversum
# Danke an die Entwickler von munki-in-a-box (Tom Bridge), run-munki-run (Graham R Pugh), Nate Felton und Rich Trouton
# Voraussetzung: mindestens macOS 10.13 Client (kein Server installiert)


# -------------------------------------------------------------
# Variables
# -------------------------------------------------------------

APPNAME="munkiverse_launcher"


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

fn_log() { echo "$APPNAME: $@"; /usr/bin/logger -t "$APPNAME" $@; }
fn_log_ok() { echo "$APPNAME: [OK] $@"; /usr/bin/logger -t "$APPNAME" [OK] $@;}
fn_log_error() { echo "$APPNAME: [ERROR] $@" 1>&2; /usr/bin/logger -p user.err -t "$APPNAME" $@;}
fn_versionCheck() {
    # Check that we are meeting the minimum version
    if [[ $(sw_vers -productVersion | awk -F. '{print $2}') -lt $1 ]]; then
        fn_log_error  "Could not run because the version of the OS does not meet requirements (macOS 10.$1 required)."
        exit 2 # Not met system requirements.
    else
        fn_log_ok  "Mac OS X 10.$(sw_vers -productVersion | awk -F. '{print $2}') or later is installed."
    fi
}
fn_rootCheck() {
    # Check that the script is NOT running as root
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
		if [[ -f /Library/Developer/CommandLineTools/usr/bin/git ]]; then
				fn_log_ok "Apple Command Line Tools already installed"
		else
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
				if [[ -f /Library/Developer/CommandLineTools/usr/bin/git ]]; then
						fn_log_ok "Apple Command Line Tools installed"
				else
						fn_log_error "Failed to install Apple Command Line Tools"
						exit 5 # Failed to install Apple Command Line Tools
				fi
		fi
}
fn_installMunki() {
	# Installing latest munkitools
	MUNKI_LATEST=$(curl https://api.github.com/repos/munki/munki/releases/latest | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["assets"][0]["browser_download_url"]')
	/usr/bin/curl -L "${MUNKI_LATEST}" -o "/tmp/munki-latest1.pkg"
	sudo /usr/sbin/installer -pkg "/tmp/munki-latest1.pkg" -target "/"
	# Check for propper installation
	if [[ -f /usr/local/munki/munkiimport ]]; then
			fn_log_ok "Newest munki installed"
	else
			fn_log_error "Failed to install munki"
			exit 6 # Failed to install munki
	fi
}
fn_installAutoPkg() {
    # Installing AutoPkg
    AUTOPKG_LATEST=$(curl https://api.github.com/repos/autopkg/autopkg/releases | python -c 'import json,sys;obj=json.load(sys.stdin);print obj[0]["assets"][0]["browser_download_url"]')
    /usr/bin/curl -L "${AUTOPKG_LATEST}" -o "/tmp/autopkg-latest1.pkg"
    sudo /usr/sbin/installer -pkg "/tmp/autopkg-latest1.pkg" -target "/"
		# Check for propper installation
		if [[ -f /Library/AutoPkg/autopkg ]]; then
				fn_log_ok "Newest AutoPkg installed"
		else
				fn_log_error "Failed to install AutoPkg"
				exit 7 # Failed to install AutoPkg
		fi
}

# MunkiAdmin

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

fn_installCommandLineTools # Installs Apple Command Line Tools for git
fn_installMunki # Installs complete munki
fn_installAutoPkg # Installs AutoPkg

exit 0
