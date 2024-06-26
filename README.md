rbbedit
=======

Easily edit server files on your workstation using [BBEdit][].

[BBEdit]: http://www.barebones.com/products/bbedit/

**Important Update: Fix for macOS "Automation Permissions"**

A new feature has been added to `rbbedit` to address the issue of missing Automation permissions when running `bbedit`
from an SSH session. Users can now request Automation permissions by passing the `-P` argument to `rbbedit`. This will
display a dialog in BBEdit, prompting the user to grant the necessary permissions for `sshd-keygen-wrapper` to control
BBEdit. The permissions only need to be requested once, to update System Settings. 

Please see the "Requesting Automation Permissions" section below for detailed instructions on how to use this new
feature.

Unleash the Power of BBEdit for Remote File Editing
-----------------------------------------------------------

As a developer or sysadmin, you often find yourself working on remote hosts, connected via SSH. While command-line
editors like vi are available on the server, you miss the rich features and intuitive interface of your favorite text
editor, BBEdit, on your macOS workstation.

That's where `rbbedit` comes in. This powerful tool bridges the gap between your local BBEdit installation and remote
file editing needs. With `rbbedit`, you can seamlessly open and edit files residing on remote hosts using the full
capabilities of BBEdit, right from your macOS workstation.

BBEdit is the leading professional HTML and text editor for macOS, crafted to serve the needs of writers, web authors,
and software developers. It provides an abundance of features for editing, searching, and manipulating prose, source
code, and textual data. By leveraging `rbbedit`, you can bring the power of BBEdit to your remote file editing workflow.

Imagine the convenience of editing Apache configuration files, server-side JavaScript, or web page content with the
familiar and feature-rich interface of BBEdit. No more struggling with command-line editors or transferring files back
and forth. With `rbbedit`, you can efficiently edit remote files as if they were local, thanks to BBEdit's built-in SFTP
support.

Whether you're tweaking configuration files, debugging scripts, or updating web content, `rbbedit` streamlines your
workflow and boosts your productivity. It allows you to leverage the full potential of BBEdit's editing capabilities
while seamlessly integrating with your remote development environment.

It's important to note that `rbbedit` is designed to open individual files rather than directories. While BBEdit
supports opening directories, `rbbedit` focuses on providing a smooth experience for editing specific files.
Additionally, `rbbedit` works with real files on disk and does not support reading from standard input (stdin) in its
current version.

If you frequently find yourself editing files on remote hosts and yearning for the power and convenience of BBEdit,
`rbbedit` is the tool you've been looking for. Embrace the efficiency and familiarity of BBEdit for your remote file
editing needs with `rbbedit`.

Usage
-----

Connect to `server-host` from the BBEdit workstation.

	workstation$ ssh server-host

Open `filename` in BBEdit on workstation, using default copy method (sftp).

	server-host$ rbbedit filename

Open `filename` in BBEdit, connecting to workstation as `myuser`.

	server-host$ rbbedit -u myuser filename

Open `filename` in BBEdit, using scp method.

	server-host$ rbbedit -m scp filename

Open `filename` in BBEdit, using ExpanDrive with volume named `expandrive-volume`.

	server-host$ rbbedit -x expandrive-volume filename

Request permission for `sshd-keygen-wrapper` to control BBEdit.

	server-host$ rbbedit -P

Send SSH public key from `server-host` to workstation.

	server-host$ rbbedit -u myuser -k send

Get SSH public key from workstation.

	server-host$ rbbedit -u myuser -k get


Requirements
------------

#### Local machine

* `sshd` must be enabled, and if needed, with firewall and port forwarding configured to allow access to BBEdit workstation
* BBEdit command line utilities
* SSH keys for user account *(to avoid entering password repeatedly)*

#### Remote machine

* `sh`
* `ssh`
* common unix utilities (such as `basename`, `dirname`, `curl`)
* SSH keys for user account *(to avoid entering password repeatedly)*


Installation
------------

#### Server Host

* Automatic installation with: 
  * `curl -L https://raw.githubusercontent.com/cngarrison/rbbedit/master/install.sh | bash`
* Or install manually from GitHub:
  * `wget https://github.com/cngarrison/rbbedit/raw/master/rbbedit`
  * `chmod 755 rbbedit`
  * Copy `rbbedit` somewhere in `PATH`
  * `cp rbbedit /usr/local/bin/`
* Or clone from GitHub:
  * `git clone https://github.com/cngarrison/rbbedit.git`
  * `cd rbbedit`
  * `./install.sh`
* Create SSH key pair for user account (unless already done)
  * `ssh-keygen`

#### BBEdit workstation

* Enable SSH (remote login)
* Configure firewall and port forwarding to allow SSH connections
* Copy SSH public key from server(s) to .ssh/authorized_keys (keys can be copied with the `-k` option)


Script options
--------------

* `-U username`: server-host/SFTP user; specify username to use in hostname argument for SFTP command - will default to $USER
* `-H hostname`: server-host/SFTP host; specify hostname or IP address - will default to $HOSTNAME
* `-u username`: workstation/SSH user; specify username to use in hostname argument for SSH command
* `-h hostname`: workstation/SSH host; specify hostname or IP address, optionally prefix with USER@, eg. myuser@myworkstation.example.com
* `-p port`: workstation/SSH port; connect to SSH using port other than 22
* `-m copy-method`: `sftp | ftp | expan | scp | rsync`  - method used to copy files between hosts
* `-x expandrive-volume`: volume name as configured in drives list of ExpanDrive, implies `-m expan`
* `-k copy-direction`: `get | send`  - direction to copy the SSH key
* `-i identity-file`: path to identity file if `ssh-copy-id` can't find default public key file
* `-y understood`: confirmation that you understand the implication of the 'copy SSH public key' command *(not required in current version)*
* `-b /path/to/bbedit`: path to `bbedit` on the workstation
* `-v`: verbose
* `-w`: Enable BBEdit wait mode (default)
* `-W`: Disable BBEdit wait mode (only sftp, ftp & expan methods)
* `-P`: Request Automation permissions for `sshd-keygen-wrapper` to control BBEdit
* `-R`: Copy `bbedit-restricted` script to the workstation and display instructions for updating `authorized_keys`
* `-+`: self-update
* `-?`: help usage

#### User Defaults

All options specified in the users ~/.rbbedit file will be used as defaults. Options specified on the command line will override user defaults.

The following options can be set in ~/.rbbedit file. These are the script default values.

	host_sftp_user=""
	host_sftp_host=""

	bbedit_ssh_user=""
	bbedit_ssh_host=""
	bbedit_ssh_port=""
		
	copy_method="sftp" # scp | expan | rsync | sftp | ftp
	expan_volume=""
	
	bbedit_prog="/usr/local/bin/bbedit"
	bbedit_wait_args=" --wait --resume"
	bbedit_wait="$bbedit_wait_args"
	
	local_ssh_copy_id_command="ssh-copy-id"
	local_key_identity=""
	bbedit_ssh_copy_id_command="/usr/local/bin/ssh-copy-id"
	bbedit_key_identity=""
	yes_agree=""
	
	verbose=0

Set default for username on BBEdit workstation:

	echo 'bbedit_ssh_user="<workstation-username"' >> ~/.rbbedit

Set default copy method to 'ftp':

	echo 'copy_method="ftp"' >> ~/.rbbedit

Set path for `bbedit`:

	echo 'bbedit_prog="/usr/bin/bbedit"' >> ~/.rbbedit

Disable the `--wait` option for `bbedit`:

	echo 'bbedit_wait=""' >> ~/.rbbedit


#### Set as EDITOR

Use rbbedit as your EDITOR, eg:

	export EDITOR="rbbedit -w"

Some programs that use EDITOR don't expect multiple arguments (& editing fails). The solutions is to create a wrapper script and use that for EDITOR.

    cat << 'EOF' > wait_rbbedit
	#!/bin/sh
	rbbedit -w "$@"
	EOF
	
	chmod +x wait_rbbedit
	mv wait_rbbedit /usr/local/bin/wait_rbbedit
	
    export EDITOR="wait_rbbedit"

Copy Methods
------------

The default copy method is 'sftp'. The 'sftp' method will construct an sftp url and use `bbedit` to open the file using BBEdit's built-in SFTP functionality.

The 'ftp' copy method is almost identical to the 'sftp' method. The difference is that the home directory will be stripped from the filename, under the assumption that the FTP server is chrooting connections. So a relative path for the filename is used, if the first part of the path matches `$HOME`. You can disable the relative path behaviour by setting `ftp_absolute=1` in your `~/.rbbedit` file.

The 'scp' method uses `scp` to copy each file to edit to the user's `TMPDIR`, then opens the file using `bbedit`. Once the file closes (editing is finished) then `scp` is used to copy file back to the server. 

The 'rsync' method is identical to 'scp' except that `rsync` is used to copy the file each direction.

The 'expan' method will instruct ExpanDrive on the workstation to mount `expandrive-volume`, and then opens the file using `bbedit`. The script can't get response indicating whether ExpanDrive has finished mounting the volume successfully, other than checking path exists, so we just sleep for 3 seconds and hope for the best.

All the commands sent from server to the workstation use `ssh`.

Multiple files can be specified at once. Only one file will opened/edited at a time. 

Only files can be specified for `scp` and `rsync` methods, while the `sftp`, `ftp` and `expan` methods will also open directories.


Requesting Automation Permissions
---------------------------------

If you encounter the following error when running `rbbedit` from an SSH session:

```
You must allow the application which is running `bbedit` to send events to the BBEdit application.
Please make appropriate changes in your Security & Privacy system preferences,
or contact your terminal/IDE application's developer for assistance.
bbedit: error: -1743
```

You can use the new `-P` argument to request Automation permissions. Run the following command from your SSH session on the server host:

```
rbbedit -P
```

This will request a "display dialog" in BBEdit, the process will request Automation permissions. Click "Granted" to complete the request. The `sshd-keygen-wrapper` can now control BBEdit.

After granting the permissions, you should see `sshd-keygen-wrapper` listed in the System Settings -> Privacy ->
Automation section, as shown in the screenshot below:

![Automation Permissions](automation-perms.png "Automation Permissions")

Once the permissions are granted, you should be able to run `rbbedit` from your SSH session without encountering the
Automation permissions error.


Restricting SSH Access with `bbedit-restricted`
----------------------------------------------

To enhance security, it's recommended to restrict SSH access to limited commands when using `rbbedit`. The
`bbedit-restricted` script helps achieve this by allowing only specific `osascript`, `bbedit`, and `bbresults` commands
to be executed via SSH.

To set up restricted access:

1. Copy the `bbedit-restricted` script to your BBEdit workstation by running the following command from your server:

   ```
   rbbedit -R
   ```

   This will copy the `bbedit-restricted` script to the `/usr/local/bin/` directory on your workstation.

2. Update your `~/.ssh/authorized_keys` file on the BBEdit workstation to include the following line:

   ```
   command="/usr/local/bin/bbedit-restricted",no-port-forwarding,no-X11-forwarding ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC... user@host
   ```

   Replace `ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC... user@host` with your actual SSH public key and user@host details.

   This line restricts the SSH access to only execute the `bbedit-restricted` script, which in turn allows only specific
`osascript`, `bbedit`, and `bbresults` commands.

By using the `bbedit-restricted` script and updating your `authorized_keys` file, you can ensure that SSH access is
limited to the necessary commands required by `rbbedit`, providing an additional layer of security.


SSH Key Copy
------------

__WARNING: *Be very sure you understand the implications of copying SSH public keys between hosts.*__ You could easily, and unitentionally,  allow user access between hosts for more than just editing files with BBEdit. This key copy feature has been added as a convenience for the `ssh-copy-id` command. Use it only if you understand what is happening.

The key copy feature depends on the `ssh-copy-id` command. It is not installed by default on OSX systems. I suggest installing the `ssh-copy-id-for-OSX` [version from GitHub](https://github.com/beautifulcode/ssh-copy-id-for-OSX):

	curl -L https://raw.githubusercontent.com/beautifulcode/ssh-copy-id-for-OSX/master/install.sh | sh

There is also a homebrew version; it has not been tested with `rbbedit`.

	brew install ssh-copy-id

For easiest use of `rbbedit`, it's best to have the __public__ SSH key on both the BBEdit workstation and the server host. (__Important:__ never share or copy your *private* SSH key.) Passing the `-k` command option with either `get` or `send` will transfer the SSH public key between hosts. Note, `put` works as an alias for `send`.

The `send` option will transfer the server host SSH public key to the BBEdit workstation. The `get` option will transfer the BBEdit workstation SSH public key to the current user account on the server host. Both options will attempt to use `ssh-copy-id` to tranfer the public key. If the `get` option fails with `ssh-copy-id`, then it will fallback to a simple `cat $bbedit_key_identity >> ~/.ssh/authorized_keys` method.

If the SSH identity file containing the public key cannot be found, you can specify which file to use with the `-i` option. Default values can also be specified in `~/.rbbedit` with either `local_key_identity` or `bbedit_key_identity` options. In addition, you can specify defaults for the path to the `ssh-copy-id` executable on each host using the `bbedit_ssh_copy_id_command` or `local_ssh_copy_id_command` options.

[*The `-y` option is not required in current version of `rbbedit`.*] You must specify `-y understood` on the command line to show your understanding of the implications of copying SSH public keys. You can also set `yes_agree="understood"` in the `~/.rbbedit` file. 

The contents of `~/.ssh/authorized_keys` on both BBEdit workstation and server host should be checked after running either the `get` or `send` key copy option. 
 
Self Updating
------------

Use the `-+` option to update `rbbedit` using the latest version from GitHub. The update is done by downloading the install.sh script and running it. 

Known Issues
------------

No error checking is done for any of the `ssh` commands (or 'copy' commands). 

To allow copying files back to server for the 'scp' and 'rsync' methods, the `bbedit` `--wait` option must be specified. 

Only real (existing) files can be edited; not text passed via STDIN. 

There is no simple/reliable way to determine whether ExpanDrive has finished mounting the remote volume, or whether there was an error. Existence of volume's path could be checked; currently the script just sleeps for 3 seconds before trying to open the file.

Copying SSH public keys between hosts should make people uncomfortable. This script only uses commonly accepted methods for copying public keys, so the author doesn't believe the script is adding additional security concerns. But neither does the author believe that using this script to simplify copying SSH public keys should absolve the user from understandind the implications of copying SSH public keys.

Project Home
------------

[rbbedit @GitHub](https://github.com/cngarrison/rbbedit/)

License
-------

[The MIT License (MIT)](http://opensource.org/licenses/MIT)
