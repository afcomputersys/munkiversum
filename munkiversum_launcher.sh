#!/bin/bash

# Installer-Script für das ganze munkiversum
# Danke an die Entwickler von munki-in-a-box (Tom Bridge) und run-munki-run (Graham R Pugh)
# Voraussetzung: mindestens macOS 10.13 Client (kein Server installiert)


# -------------------------------------------------------------
# Variablen
# -------------------------------------------------------------

LOGGER="/usr/bin/logger -t munkiverse"


# -------------------------------------------------------------
# Make sure the whole script stops if Control-C is pressed.
# -------------------------------------------------------------
fn_terminate() {
    echo "munkiversum_launcher has been terminated."
    exit 1 # SIGINT caught
}
trap 'fn_terminate' SIGINT



# Anfang (von munkiinabox)
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
	exit 6 "You are not an admin user, you need to do this as an admin user."
fi




# -------------------------------------------------------------
# Functions
# -------------------------------------------------------------

fn_versionCheck() {
    # Check that we are meeting the minimum version
		# Thanks Rich Trouton, Tom Bridge, Graham R Pugh
    if [[ $(sw_vers -productVersion | awk -F. '{print $2}') -lt $1 ]]; then
        ${LOGGER} "### Could not run because the version of the OS does not meet requirements."
        exit 2 # Not met system requirements.
    else
        ${LOGGER} "Mac OS X 10.$(sw_vers -productVersion | awk -F. '{print $2}') or later is installed. Proceeding..."
    fi
}
fn_rootCheck() {
    # Check that the script is NOT running as root
		# Thanks Tom Bridge, Graham R Pugh
    if [[ $EUID -eq 0 ]]; then
        ${LOGGER} "### This script is NOT MEANT to run as root. This script is meant to be run as an admin user. I'm going to quit now. Run me without the sudo, please."
        exit 3 # Running as root.
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

fn_versionCheck 13 # check macOS Version; at least 10.[VARIABLE1]
fn_rootCheck # Check that the script is NOT running as root


exit 0
