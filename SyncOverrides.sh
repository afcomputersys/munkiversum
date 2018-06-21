#!/bin/sh

####
# Script, welches den AutoPkg-RecipeOverrides-Ordnerinhalt synchron hält.
####
# Voraussetzung: git und AutoPkg(r) sind installiert und konfiguriert.
####
# A&F/MSH 20.06.2018
####

# Parameter zum anpassen:
WEB_OVERRIDE_DIR="https://github.com/afcomputersys/autopkg-overrides"

# automatische Parameter:
LOCAL_OVERRIDE_DIR=$(defaults read com.github.autopkg RECIPE_OVERRIDE_DIRS)

# Klont WEB_OVERRIDE_DIR per git, falls im Override-Ordner noch kein .git vorhanden ist
if [ -e "$LOCAL_OVERRIDE_DIR/.git" ]
then
  echo "Initialer 'git clone' wurde schon erfolgreich ausgeführt!"
else
  git clone "$WEB_OVERRIDE_DIR" "$LOCAL_OVERRIDE_DIR"
fi

# setzt master als aktiver branch.
git -C "$LOCAL_OVERRIDE_DIR" checkout master

# löscht/resettet in LOCAL_OVERRIDE_DIR gemachte Änderungen an bestehenden Dateien.
git -C "$LOCAL_OVERRIDE_DIR" stash

# synchronisiert WEB_OVERRIDE_DIR nach LOCAL_OVERRIDE_DIR.
git -C "$LOCAL_OVERRIDE_DIR" pull

# führt ein update-trust-info aller Overrides aus.
OVERRIDEFILES="$LOCAL_OVERRIDE_DIR/*"
for f in $OVERRIDEFILES
do
  if [[ "$f" == *"recipe"* ]]
  then
    yes | autopkg update-trust-info $f
  fi
done

# aktiviert alle Overrides in AutoPkgr recipe_list.txt in ""/Users/AKTIVER_USER/Library/Application Support/AutoPkgr"
RECIPE_LIST_TXT="$HOME/Library/Application Support/AutoPkgr/recipe_list.txt"
rm "$RECIPE_LIST_TXT"
OVERRIDEFILES="$LOCAL_OVERRIDE_DIR/*"
for f in $OVERRIDEFILES
do
  if [[ "$f" == *"recipe"* ]]
  then
    RECIPE_LIST_TXT_ELEMENT=$(/usr/libexec/PlistBuddy -c "Print :Identifier" $f)
    echo "$RECIPE_LIST_TXT_ELEMENT" >> "$RECIPE_LIST_TXT"
  fi
done
echo "MakeCatalogs.munki" >> "$RECIPE_LIST_TXT"


exit 0
