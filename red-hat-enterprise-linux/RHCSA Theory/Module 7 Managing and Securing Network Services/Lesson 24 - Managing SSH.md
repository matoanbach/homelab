## Lesson 24: Managing SSH
- 24.1 Understanding SSH Key-based Login
- 24.2 Setting up SSH Key-based Login
- 24.3 Caching SSH Keys
- 24.4 Defining SSH Client Configuration
- 24.5 Exploring Common SSH Server Options
- 24.6 Copying Files Securely
- 24.7 Synchronizing Files Securely

## 24.2 Setting up SSH Key-based login
### Understanding the Procedure
- `ssh-keygen` runs on your local machine (the client). It creates two files:
    1. A private key (e.g. ~/.ssh/id_rsa) - keep this secret
    2. A public key (e.g ~/.ssh/id_rsa.pub) - this is safe to share
- `ssh-copy-id user@server` runs from the client. It takes your public key (id_rsa.pub) and appends it to the server user's `~/.ssh/authorized_key` file. After that, when you `ssh user@server`, your client provides the private key and the server verifies it against the public key in authorized_keys. If they match, you log in without typing a password.

## 24.3 Caching SSH Keys
### Understanding `ssh-agent`
- When your private key is protected by a passphrase, you normally have to type that passphrase each time you SSH
- `ssh-agent /bin/bash` starts a background agent and ties it to your current shell session. It allocates memory that can hold decrypted keys
- `ssh-add` once and enter the passphrase for each key you want to use. The agent caches those decrypted keys in memory
- For the rest of your shell session (and any child processes), SSH clients will ask the agent for the key rather tahn prompting you again - so you only type each passphrase once per login session 

## 24.4 Defining SSH Client Configuration
### Understanding SSH Client Options
- `ssh -X user@host` enables X11 forwarding so graphical applications you launch on the remote host will display on your local machine. This is the "untrusted" mode, meaning the remote X11 server has extra restrictions for security
- `ssh -Y user@host` enables X11 forwading. It removes many of the security restrictions imposed by -X. Use this only if you trust the remote host and need full X11 functionality
- Masking options permanent. Instead of type -X or -Y every time, you can add them to your SSH client configuration. Edit either
    - **System-wide**: /etc/ssh/sshd_config
    - **User-specific**: ~/.ssh/ssh_config

## 24.5 Exploring Common Server SSH Server Options
- Server options are set in `/etc/ssh/sshd_config` 
    - Port 22
    - PermitRootLogin
    - PubkeyAuthentication
    - PasswordAuthentication
    - X11Forwarding
    - AllowUsers

## 24.6 Copying Files Securely
- `scp` can be used to securely copy files over the network, using the `sshd` process
    - `scp file1 file2 student@remoteserver:/home/student`
    - `scp -r root@remoteserver:/tmp/files`
- `sftp` offers an FTP client interface to securely transfer files using SSH
    - `put /my/file` to upload a file
    - `get /your/file` to download a file to the current directory
    - `exit` to chose an `sftp` session

## 24.7 Synchronizing Files Securely
- `rsync` is using SSH to synchronize files
- If source and target files already exists, `rsync` will only synchronize their differences
- The `rsync` command can be used with many options, of which the following are most common
    - `-r` will recursively synchronize the entire directory tree
    - `-l` synchronize symbolic links
    - `-p` preserves symbolic links
    - `-n` will do a dry run before actually synchronizing
    - `-a` uses archive mode, which is equivalent to `-rlptgoD`
    - `-A` uses archive mode and also synchronizes ACLs
    - `-X` will synchronize SELinux context as well

## Lesson 24 Lab: Managing SSH
- Set up your SSH server in such a way that:
    - SSH offers services on port 22
    - User root is allowed to log in
    - Graphical sessions can be forwarded
- Verify that X forwarding works from the SSH client
- To perform this lab, use `localhost` as the server address