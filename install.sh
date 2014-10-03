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

if [ ! -z $RBBEDIT_INSTALL_PATH ]; then
	rbbedit_path=$RBBEDIT_INSTALL_PATH
else 
	rbbedit_path="/usr/local/bin/rbbedit"
fi
install_path=`dirname $rbbedit_path`

if git ls-files >& /dev/null &&  [[ -f rbbedit ]]; then
	$SUDO cp rbbedit $rbbedit_path || { echo "Failed to install rbbedit into $install_path"; exit 1; }
else
	$SUDO curl -L https://raw.githubusercontent.com/cngarrison/rbbedit/master/rbbedit -o $rbbedit_path || { echo "Failed to install rbbedit into $install_path"; exit 1; }
	$SUDO chmod +x $rbbedit_path || { echo "Failed to install rbbedit into $install_path"; exit 1; }
fi
echo "Installed rbbedit into $install_path"; exit 0;


# Local Variables:
# tab-width: 3
# x-auto-expand-tabs: true
# End:
