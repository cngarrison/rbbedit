rbbedit
=======

Edit local (server) files on remote (users) workstation using [BBEdit][].

[BBEdit]: http://www.barebones.com/products/bbedit/


Usage
-----

	workstation$ ssh server-host

Connect to server-host from the BBEdit workstation.

	server-host$ rbbedit filename

Open filename on workstation using default copy method (sftp).

	server-host$ rbbedit -u myuser filename

Open filename on workstation, connecting to workstation as 'myuser'.

	server-host$ rbbedit -m scp filename

Open filename on workstation using scp method.

	server-host$ rbbedit -x expandrive-volume filename

Open filename on workstation using ExpanDrive.

	server-host$ rbbedit -u myuser -k send

Send SSH public key from server-host to workstation.

	server-host$ rbbedit -u myuser -k get

Get SSH public key from workstation.


Requirements
------------

#### Local machine

* `sshd` must be enabled with firewall and port forwarding configured to allow access to BBEdit workstation
* BBEdit command line utilities

#### Remote machine

* `sh`
* `ssh`
* common unix utilities (such as `basename`)
* ssh keys for user account (to avoid entering workstation password)


Installation
------------

#### Server Host

* Copy `rbbedit` anywhere in `PATH`:
* Or install from GitHub:
  * `wget https://github.com/cngarrison/rbbedit/raw/master/rbbedit`
  * `chmod 755 rbbedit`
* Create ssh key pair for user account (unless already done)

#### BBEdit workstation

* Enable ssh (remote login)
* Configure firewall and port forwarding to allow ssh connections
* Copy ssh public key from server(s) to .ssh/authorized_keys


Script options
--------------

* `-u username`: workstation/ssh user; specify username to use in hostname argument for ssh command
* `-h hostname`: workstation/ssh host; specify hostname or IP address, optionally prefix with USER@, eg. myuser@myworkstation.example.com
* `-p port`: workstation/ssh port; connect to ssh using port other than 22
* `-m copy-method`: `sftp | expan | scp | rsync`  - method used to copy files between hosts
* `-x expandrive-volume`: volume name as configured in drives list of ExpanDrive, implies `-m expan`
* `-k copy-direction`: `get | send`  - direction to copy the SSH key
* `-i identity-file`: path to identity file if `ssh-copy-id` can't find default public key file
* `-y understood`: confirmation that you understand the implication of the 'copy SSH public key' command *(not required in current version)*
* `-v`: verbose
* `-w`: Enable BBEdit wait mode (default)
* `-w`: Disable BBEdit wait mode (only sftp & expan methods)

#### User Defaults

All options specified in the users ~/.rbbedit file will be used as defaults. Options specified on the command line will override user defaults.

The following options can be set in ~/.rbbedit file. These are the script default values.

	bbedit_ssh_user=""
	bbedit_ssh_host=""
	bbedit_ssh_port=""
		
	copy_method="sftp" # scp | expan | rsync | sftp
	expan_volume=""
	
	bbedit_wait_args=" --wait --resume"
	bbedit_wait="$bbedit_wait_args"
	
	local_ssh_copy_id_command="ssh-copy-id"
	local_key_identity=""
	bbedit_ssh_copy_id_command="/usr/local/bin/ssh-copy-id"
	bbedit_key_identity=""
	yes_agree=""
	
	verbose=0

#### Set as EDITOR

Use rbbedit as your EDITOR, eg:

	export EDITOR="rbbedit -w"


Copy Methods
------------

The default copy method is 'sftp'. The 'sftp' method will construct an sftp url and use `bbedit` to open the file using BBEdit's built-in SFTP functionality.

The 'scp' method uses `scp` to copy each file to edit to the user's `TMPDIR`, then opens the file using `bbedit`. Once the file closes (editing is finished) then `scp` is used to copy file back to the server. 

The 'rsync' method is identical to 'scp' except that `rsync` is used to copy the file each direction.

The 'expan' method will instruct ExpanDrive on the workstation to mount `expandrive-volume`, and then opens the file using `bbedit`. The script can't get response indicating whether ExpanDrive has finished mounting the volume successfully, other than checking path exists, so we just sleep for 3 seconds and hope for the best.

All the commands sent from server to the workstation use ssh.

Multiple files can be specified at once. Only one file will opened/edited at a time. 

Only files can be specified for `scp` and `rsync` methods, while the `sftp` and `expan` methods will also open directories.

SSH Key Copy
------------

__WARNING: *Be very sure you understand the implications of copying SSH public keys between hosts.*__ You could easily, and unitentionally,  allow user access between hosts for more than just editing files with BBEdit. This key copy feature has been added as a convenience for the `ssh-copy-id` command. Use it only if you understand what is happening.

The key copy feature depends on the `ssh-copy-id` command. It is not installed by default on OSX systems. I suggest installing the `ssh-copy-id-for-OSX` version from GitHub:

	curl -L https://raw.githubusercontent.com/beautifulcode/ssh-copy-id-for-OSX/master/install.sh | sh

There is also a homebrew version; it has not been tested with `rbbedit`.

	brew install ssh-copy-id

For easiest use of `rbbedit`, it's best to have the __public__ SSH key on both the BBEdit workstation and the server host. (__Important:__ never share or copy your *private* SSH key.) Passing the `-k` command option with either `get` or `send` will transfer the SSH public key between hosts. Note, `put` works as an alias for `send`.

The `send` option will transfer the server host SSH public key to the BBEdit workstation. The `get` option will transfer the BBEdit workstation SSH public key to the current user account on the server host. Both options will attempt to use `ssh-copy-id` to tranfer the public key. If the `get` option fails with `ssh-copy-id`, then it will fallback to a simple `cat $bbedit_key_identity >> ~/.ssh/authorized_keys` method.

If the SSH identity file containing the public key cannot be found, you can specify which file to use with the `-i` option. Default values can also be specified in `~/.rbbedit` with either `local_key_identity` or `bbedit_key_identity` options. In addition, you can specify defaults for the path to the `ssh-copy-id` executable on each host using the `bbedit_ssh_copy_id_command` or `local_ssh_copy_id_command` options.

[*The `-y` option is not required in current version of `rbbedit`.*] You must specify `-y understood` on the command line to show your understanding of the implications of copying SSH public keys. You can also set `yes_agree="understood"` in the `~/.rbbedit` file. 

The contents of `~/.ssh/authorized_keys` on both BBEdit workstation and server host should be checked after running either the `get` or `send` key copy option. 
 
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
