#!/bin/bash

# Installer-Script für das ganze munkiversum

# Voraussetzung: macOS 10.13 Client (kein Server installiert)

# Variablen
LOGGER="/usr/bin/logger -t munkiverse"




# Anfang
echo "Start ins MUNKIVERSUM"'!'
echo "Sind Sie ein Benutzer mit Administratoren-Rechten? Bitte geben Sie Ihr Passwort ein."
#Let's see if this works...
#This isn't bulletproof, but this is a basic test.
sudo whoami > /tmp/quickytest
if
	[[  `cat /tmp/quickytest` == "root" ]]; then
	${LOGGER} "Privilege Escalation Allowed, Please Continue."
	else
	${LOGGER} "Privilege Escalation Denied, User Cannot Sudo."
	exit 6 "You are not an admin user, you need to do this an admin user."
fi



${LOGGER} "Starting checks..."
# Make sure the whole script stops if Control-C is pressed.
fn_terminate() {
    fn_log_error "Munki-in-a-Box has been terminated."
    exit 1
}
trap 'fn_terminate' SIGINT

if
    [[ $osvers -lt 13 ]]; then
    ${LOGGER} "Could not run because the version of the OS does not meet requirements"
    echo "Sorry, this is for Mac OS 10.13 or later."
    exit 2 # not 10.13+ System
fi
${LOGGER} "macOS 10.13 or later is installed."

if
    [[ $EUID -eq 0 ]]; then
   $echo "This script is NOT MEANT to run as root. This script is meant to be run as an admin user. I'm going to quit now. Run me without the sudo, please."
    exit 4 # Running as root.
fi



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
