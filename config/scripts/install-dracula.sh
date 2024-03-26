#!/usr/bin/env bash

set -euo pipefail

curl -JL -o dracula.zip "https://github.com/dracula/gtk/archive/master.zip"
unzip dracula.zip
mv gtk-master dracula
mv dracula /usr/share/themes
