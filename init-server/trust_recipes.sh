#!/bin/bash
FILES=/Users/admin/Library/AutoPkg/RecipeOverrides/*
for f in $FILES
do
  yes | autopkg update-trust-info $f
done
