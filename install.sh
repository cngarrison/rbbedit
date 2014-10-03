#!/bin/sh
# Installs rbbedit into /usr/local/bin
# Installer ideas from https://github.com/beautifulcode/ssh-copy-id-for-OSX

if [[ $(id -u) != 0 ]]; then
	if command -v sudo >/dev/null 2>&1; then
		SUDO="sudo"
	else
		echo >&2 "Requires sudo but it's not installed. Aborting."
		exit 1
	fi
fi

if git ls-files >& /dev/null &&  [[ -f rbbedit ]]; then
	$SUDO cp rbbedit /usr/local/bin/rbbedit || { echo "Failed to install rbbedit into /usr/local/bin."; exit 1; }
else
	$SUDO curl -L https://raw.githubusercontent.com/cngarrison/rbbedit/master/rbbedit -o /usr/local/bin/rbbedit || { echo "Failed to install rbbedit into /usr/local/bin."; exit 1; }
	$SUDO chmod +x /usr/local/bin/rbbedit || { echo "Failed to install rbbedit into /usr/local/bin."; exit 1; }
fi
echo "Installed rbbedit into /usr/local/bin."; exit 0;
