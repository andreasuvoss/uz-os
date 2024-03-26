#!/usr/bin/env bash

set -euo pipefail

git clone https://github.com/corecoding/Vitals.git /usr/share/gnome-shell/extensions/Vitals@CoreCoding.com -b develop


git clone https://gitlab.gnome.org/jrahmatzadeh/just-perfection.git tmp

gnome-extensions pack ./tmp/src \
    --force \
    --podir="../po" \
    --extra-source="bin" \
    --extra-source="lib" \
    --extra-source="ui" \
    --extra-source="../LICENSE" \
    --extra-source="../CHANGELOG.md"

unzip just-perfection-desktop@just-perfection.shell-extension.zip -d /usr/share/gnome-shell/extensions/just-perfection-desktop@just-perfection

cp /usr/share/gnome-shell/extensions/just-perfection-desktop@just-perfection/schemas/org.gnome.shell.extensions.just-perfection.gschema.xml /usr/share/glib-2.0/schemas/

glib-compile-schemas /usr/share/glib-2.0/schemas/
