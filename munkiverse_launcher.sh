#!/bin/bash

# Installer-Script für das ganze munkiverse
# Danke an die Entwickler von munki-in-a-box (Tom Bridge), run-munki-run (Graham R Pugh), Nate Felton und Rich Trouton
# Voraussetzung: mindestens macOS 10.13 Client (kein Server installiert)

###############################################################
### ToDo / Ideen
### ------------
### Separates Script oder interne Funktion (bei Scriptbeginn, mit eigenem Error; macht dann andere Schleifen überflüssig), um vorher alle munkiverse-Bestandteile (repos, overrides, etc.) zu sichern und zu deinstallieren. Dies, falls eine Migrations eines manuellen munki-Servers gemacht werden soll.
### Setting-File mit Überprüfung 'includen'
### Installationsweiche, falls Server.app installiert und eingerichtet ist.
### Git-File mit MunkiReport-Modulauswahl pro Kunde
### munkiverse-main.sh, das Unsterscripts periodisch ausführt
### A&F-Secure-Server zur Übermittlung sensibler Passwörter?
### Sicherheit. Alles möglichst verschlüsseln und https etc.
### GOGS "Free own GitHub Server"
###############################################################

# -------------------------------------------------------------
# Variables
# -------------------------------------------------------------

# ZU VERSCHIEBEN IN SETTING-FILE
REPOLOC="/Users/Shared/munkiverse"
REPONAME="repo"

# Scriptinterne Variablen
APPNAME="munkiverse_launcher"
REPODIR="${REPOLOC}/${REPONAME}"
DEFAULTS="/usr/bin/defaults"
AUTOPKG="/usr/local/bin/autopkg"

# -------------------------------------------------------------
# Make sure the whole script stops if Control-C is pressed.
# -------------------------------------------------------------

fn_terminate() {
    echo "munkiverse_launcher has been terminated."
    exit 1 # SIGINT caught
}
trap 'fn_terminate' SIGINT


# -------------------------------------------------------------
# Functions
# -------------------------------------------------------------

fn_log() { echo "$APPNAME: $@"; /usr/bin/logger -t "$APPNAME" $@; }
fn_log_ok() { echo "$APPNAME: [OK] $@"; /usr/bin/logger -t "$APPNAME" [OK] $@; }
fn_log_error() { echo "$APPNAME: [ERROR] $@" 1>&2; /usr/bin/logger -p user.err -t "$APPNAME" $@; }
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
fn_installAutoPkg() {
  # Installing AutoPkg
  AUTOPKG_LATEST=$(/usr/bin/curl -s https://api.github.com/repos/autopkg/autopkg/releases | python -c 'import json,sys;obj=json.load(sys.stdin);print obj[0]["assets"][0]["browser_download_url"]')
  /usr/bin/curl -s -L "${AUTOPKG_LATEST}" -o "/tmp/autopkg-latest1.pkg"
  sudo /usr/sbin/installer -pkg "/tmp/autopkg-latest1.pkg" -target "/"
  rm "/tmp/autopkg-latest1.pkg"
	# Check for propper installation
	if [[ -x /usr/local/bin/autopkg ]]; then
			fn_log_ok "Newest AutoPkg installed"
	else
			fn_log_error "Failed to install AutoPkg"
			exit 7 # Failed to install AutoPkg
	fi
}
fn_installMunki() {
	# Installing latest munkitools
	MUNKI_LATEST=$(/usr/bin/curl -s https://api.github.com/repos/munki/munki/releases/latest | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["assets"][0]["browser_download_url"]')
	/usr/bin/curl -s -L "${MUNKI_LATEST}" -o "/tmp/munki-latest1.pkg"
	sudo /usr/sbin/installer -pkg "/tmp/munki-latest1.pkg" -target "/"
  rm "/tmp/munki-latest1.pkg"
	# Check for propper installation
	if [[ -f /usr/local/munki/munkiimport ]]; then
			fn_log_ok "Newest munki installed"
	else
			fn_log_error "Failed to install munki"
			exit 6 # Failed to install munki
	fi
}
fn_configureAutoPkg() {
  if [[ -f "${REPOLOC}/autopkg" ]]; then
      fn_log_error "AutoPkg folders already exists. Aborting."
      exit 9 # AutoPkg folders already exists
  else
      mkdir -p "${REPOLOC}/autopkg"
    	mkdir "${REPOLOC}/autopkg/RecipeRepos"
    	mkdir "${REPOLOC}/autopkg/RecipeOverrides"
    	mkdir "${REPOLOC}/autopkg/Cache"
	    sudo ln -s "${REPODIR}" /Library/WebServer/Documents/
      fn_log_ok "AutoPkg folders created in ${REPOLOC}/autopkg"
  fi
  # Define paths for AutoPkg
  ${DEFAULTS} write com.github.autopkg MUNKI_REPO "$REPODIR"
  ${DEFAULTS} write com.github.autopkg CACHE_DIR "${REPOLOC}/autopkg/Cache"
  ${DEFAULTS} write com.github.autopkg RECIPE_OVERRIDE_DIRS "${REPOLOC}/autopkg/RecipeOverrides"
  ${DEFAULTS} write com.github.autopkg RECIPE_REPO_DIR "${REPOLOC}/autopkg/RecipeRepos"
  fn_log_ok "AutPkg configured"
}
fn_configureMunki() {
  # Creates repo-folder and subfolder with correct permissions
  if [[ -f "${REPODIR}" ]]; then
      fn_log_error "Munki Repo already exists. Aborting."
      exit 10 # Munki Repo already exists
  else
      mkdir -p "${REPODIR}"
    	mkdir "${REPODIR}/catalogs"
    	mkdir "${REPODIR}/manifests"
    	mkdir "${REPODIR}/pkgs"
    	mkdir "${REPODIR}/pkgsinfo"
    	mkdir "${REPODIR}/icons"
	    chmod -R a+rX,g+w "${REPODIR}"
	    chown -R $EUID:80 "${REPODIR}"
	    sudo ln -s "${REPODIR}" /Library/WebServer/Documents/
      fn_log_ok "munki repo-folder created in ${REPODIR}"
  fi
  # Define paths and settings for munki
  ${DEFAULTS} write com.googlecode.munki.munkiimport editor "Atom.app"
  ${DEFAULTS} write com.googlecode.munki.munkiimport repo_path "${REPODIR}"
  ${DEFAULTS} write com.googlecode.munki.munkiimport pkginfo_extension .plist
  ${DEFAULTS} write com.googlecode.munki.munkiimport default_catalog new
  # This makes AutoPkg useful on future runs for the admin user defined at the top. It copies & creates preferences for autopkg and munki into their home dir's Library folder, as well as transfers ownership for the ~/Library/AutoPkg folders to them.
  plutil -convert xml1 ~/Library/Preferences/com.googlecode.munki.munkiimport.plist
  fn_log_ok "munki configured"
}
fn_cloneGitMunkiverse() {
  # clone munkiverse git
  mkdir -p "/${REPOLOC}/gitclones"
  git -C "/${REPOLOC}/gitclones" clone https://github.com/afcomputersys/munkiverse.git
}
fn_runInitServer() {
  # Install additional Server Tools from init-server/recipe_list.txt (git)
  for f in "/${REPOLOC}/gitclones/munkiverse/init-server/overrides/*"
  do
    yes | autopkg update-trust-info $f
  done

  # overrides ausführen
  # server-manifest erstellen und konfigurieren
  # ServerTools installieren (mangedsoftwareupdate)
  # repo wieder aufräumen und autopkg zurücksetzen
}

fn_installMunkiAdmin() {
  # Installing MunkiAdmin
  if [[ -d /Applications/MunkiAdmin.app ]]; then
    sudo rm -R "/Applications/MunkiAdmin.app"
  fi
  MUNKIADMIN_LATEST=$(/usr/bin/curl -s https://api.github.com/repos/hjuutilainen/munkiadmin/releases | python -c 'import json,sys;obj=json.load(sys.stdin);print obj[0]["assets"][0]["browser_download_url"]')
  /usr/bin/curl -s -L "${MUNKIADMIN_LATEST}" -o "/tmp/munkiadmin-latest1.dmg"
  hdiutil attach -quiet -mountpoint "/Volumes/MunkiAdminLatest" "/tmp/munkiadmin-latest1.dmg"
  cp -r "/Volumes/MunkiAdminLatest/MunkiAdmin.app" "/Applications/MunkiAdmin.app"
  hdiutil unmount -quiet "/Volumes/MunkiAdminLatest"
  rm "/tmp/munkiadmin-latest1.dmg"
	# Check for propper installation
	if [[ -d /Applications/MunkiAdmin.app ]]; then
			fn_log_ok "Newest MunkiAdmin installed"
	else
			fn_log_error "Failed to install MunkiAdmin"
			exit 7 # Failed to install MunkiAdmin
	fi
}
fn_startApache() {
	# Start Apache WebServer
	sudo apachectl start
}

# Create own Server-Manifest,

# munkireport-php (über autopkg installieren? Munki & MunkiAdmin etc. auch? ServerinstallStart-RecipeList auf GitHub)

# Watchman

# Slack

# Deploystudio

# NetBoot alternative

# Adobe CCP

# Config Watchman
# Config MunkiAdmin
# Config MunkiReport
# Config NetBoot
# Config Deploystudio
# Config Slack

# Caching-Server?

# syncoverrides.sh
# trello_integration.sh


# -------------------------------------------------------------
# Execute functions and others
# -------------------------------------------------------------

echo "Launch to MUNKIVERSE"'!'

echo "Performing Tests"
fn_versionCheck 13 # check macOS Version; at least 10.[$1]
fn_rootCheck # Check that the script is NOT running as root
fn_adminCheck # Check that the script is running as an admin user
# Tests include-Variables
# Tests for prior Installation with cleaning and backup
# Free Disk-Space Test

echo "Installing core software for munkiverse"
fn_installCommandLineTools # Installs Apple Command Line Tools for git
fn_installAutoPkg # Installs AutoPkg
fn_installMunki # Installs complete munki

echo "Create Init-Config"
fn_configureMunki # Creates repo-folder and set paths
fn_configureAutoPkg # Creates AutoPkg folders and set paths
fn_startApache # Start Apache WebServer

echo "Installing addional ServerTools and munkiverse-Scripts"
fn_installMunkiAdmin # Installs MunkiAdmin

echo "Configure munkiverse"
# Alle Konfigurationen

echo "The launch to munkiverse had no problems. So go on - here are your essential Links and Login-Informations. Make a copy!"
# Slack-login
# Trello-login
# ?Manifest-Creator-Login?
# Ansprechspersonen A&F


exit 0