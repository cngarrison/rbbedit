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

	server-host$ rbbedit -m scp filename

Open filename on workstation using scp method.

	server-host$ rbbedit -x expandrive-volume filename

Open filename on workstation using ExpanDrive.


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

* `-h hostname`: workstation/ssh host; specify hostname or IP address, optionally prefix with USER@, eg. myuser@myworkstation.example.com
* `-p port`: workstation/ssh port; connect to ssh using port other than 22
* `-m copy-method`: sftp | expan | scp | rsync
* `-x expandrive-volume`: volume name as configured in drives list of ExpanDrive, implies `-m expan`
* `-v`: verbose


Copy Methods
------------

The default copy method is 'sftp'. The 'sftp' method will construct an sftp url and use `bbedit` to open the file using BBEdit's built-in SFTP functionality.

The 'scp' method uses `scp` to copy each file to edit to the user's `TMPDIR`, then opens the file using `bbedit`. Once the file closes (editing is finished) then `scp` is used to copy file back to the server. 

The 'rsync' method is identical to 'scp' except that `rsync` is used to copy the file each direction.

The 'expan' method will instruct ExpanDrive on the workstation to mount `expandrive-volume`, and then opens the file using `bbedit`. The script can't get response indicating whether ExpanDrive has finished mounting the volume successfully, other than checking path exists, so we just sleep for 3 seconds and hope for the best.

All the commands sent from server to the workstation use ssh.

Multiple files can be specified at once. Only one file will opened/edited at a time. 


Known Issues
------------

No error checking is done for any of the `ssh` commands (or 'copy' commands). 

To allow copying files back to server for the 'scp' and 'rsync' methods, the `bbedit` `--wait` option must be specified. The `wait` option is currently hard-coded for all copy methods. It should be optional for the 'sftp' and 'expan' methods.

Only real (existing) files can be edited; not text passed via STDIN. 

There is no simple/reliable way to determine whether ExpanDrive has finished mounting the remote volume, or whether there was an error. Existence of volume's path could be checked; currently the script just sleeps for 3 seconds before trying to open the file.


License
-------

[The MIT License (MIT)](http://opensource.org/licenses/MIT)
