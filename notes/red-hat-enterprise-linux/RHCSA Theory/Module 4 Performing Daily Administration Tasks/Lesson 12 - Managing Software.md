# Lesson 12 Managing Software
- 12.1 Understanding RPM Packages
- 12.2 Setting up Repository Access
- 12.3 Managing Packages with `dnf`
- 12.4 Using `dnf` Groups
- 12.5 Exploring Modules and Application Streams
- 12.6 Managing `dnf` Updates and History
- 12.7 Using subscription-manager

## 12.1 Understanding RPM Packages
- Software on RHEL is installed using packages in Red Hat Package Manager (RPM) format
- An RPM package contains a compressed archive, as well as package metadata
- In the metadata, package dependencies are identified
- To hanlde dependency management, RHEL uses repositories for package installation
- If a dependency was found, it is installed automatically from the repository
- Installed packages are registered in the RPM database

### Managing RPM Packages
- The `rpm` command can be used for some package management tasks
- Some commands query the RPM database
    - `rpm -qa` shows all packages that are currently installed
    - `rpm -qf filename` shows from which package filename was installed
    - `rpm -ql` lists files installed from a package
    - `rpm -q --scripts` shows scripts executed while installing the package
    - `rpm -q --changelog` shows the change log for a package
- Querying package files is also possible
    - Add `-p` to any of the commands above

### Extracting RPM Packages
- You can peek into or unpack an RPM without installing it by piping `rpm2cio` into `cpio`:
    - `rpm2cpio mypackage-1.0.rpm | cpio -t` to show all files inside the RPM
    - `rpm2cpio mypackage-1.0.rpm | cpio -idmv` to unpack files into your current directory
        - `-i` is to extract
        - `-d` is to create directories as needed
        - `-m` is to preserve timestamps
        - `-v` is verbose output

## 12.2 Setting up Repository Access
- A repository is a collection of RPM package files with an index that contains the repository contents
- Repositories are often offered through web sites, but local repositories can be created also
- The `dnf` command is used as the default command to install packages from repositories
- In RHEL 9, `dnf` is preferred over the `yum` command which aws used in previous versions of RHEL
- `dnf` and `yum` are offering the same functionality

### Accessing Repositories
- To access repositories, a RHEL system must be registered using `subscription-manager`
- `subscription-manager` tries to access the online Red Hat repositories
- As an alternative to online repositories, repositories can be offered through Red Hat Satellite
- If no Internet connection, nor Red Hat Statellite are available, no repositories will be available by default
- In that case, you'll have to manually configure repository access

### Manually Configuring Repository Access
- To access repositories that are offered through subscription manager, use `dnf config-manager --enable name-of-the-repository` to add repository access
- Third party repositories can be added using a repo file in `/etc/yum.repos.d/`, or using `dnf config-manager`
    - `dnf config-manager --add-repo="file:///repo/AppStream"`
    - `cat >> /etc/yum.repos.d/AppStream.repo << EOF`

### Demo: Configuring the Installation Disk as Repo
- This procedure is NOT required on the exam. You'll need it to set up your own lab environment
    - `df -h` - you need 10GB free disk space on `/`
    - `dd if=/dev/sr0 of=/rhel9.iso bs=1M`
    - `mkdir /repo`
    - `cp /etc/fstab /etc/fstab.bak`
    - `echo "/rhel9.iso /repo iso9660 defaults 0 0" >> /etc/fstab` 
    - `mount -a`
- If you don't have 10 GB free space in `/`
    - `mkdir /repo`
    - `echo "/dev/sr0 /repo iso9660 defaults 0 0" >> /etc/fstab`

### Demo: Configuring Repository Access
- `dnf config-manager --add-repo="file:///repo/BaseOS"`
- `dnf config-manager --add-repo="file:///repo/AppStream"`
- `dnf repolist` to list installed config files for repos
- `ls /etc/yum.repos.d`

### Using GPG keys
- GPG signatures prove that RPMs come from the right source and haven'y been tampered with.
- How it works:
    1. The repository maintainer signs each package with their private GPG key.
    2. Your system uses the corresponding public key to check that signature before installing
- How to use:
    1. Import the repo's public key `rpm --import /path/to/RPM-GPG-KEY`
    2. In your repo file (`/etc/yum.repos.d/*.repo`), enable checking
    ```txt
    gpgcheck=1
    gpgkey=file:///path/to/RPM-GPG-KEY
    ```
- You can set `gpgcheck=0` to skip verification (not recommended unless you fully trust the source)

## 12.3 Managing Packages with `dnf`
- `dnf` was created to be intuitive
    - `dnf list` lists installed and available packages
        - `dnf list 'selinux'` 
    - `dnf search` searches in name and summary. Use `dnf search all` to search in description as well
        - `dnf search seinfo`
        - `dnf search all seinfo`
    - `dnf provides` searches in package file lists for the package that provides a specific file
        - `dnf provides */Containerfile`
        - `dnf info` shows information about the package

### Managing Packages with `dnf`
- `dnf install` installs packages as well as any dependencies
- `dnf remove` removes packages, as well as packages depending on this package - potentially dangerous!
- `dnf update` compares current package version with the package version listed in the repository and updates if necessary
    - `dnf update kernel` will install the new kernel and keeps the old kernel as a backup

## 12.4 Using dnf Groups
- Use `dnf group info <groupname>` to see packages within a group 
- Packages are marked as mandatory, default, or optional
- While using `dns group install`, only mandatory and default packages are installed
- To install optional packages also, use `dnf group install --with-optional`
- As group names often contain spaces, the entire group name must be referred to using double quotes

### Understanding Modularity
- `dnf` uses modularity, meaning that different versions of the same package can be maintained in the same repository
- Modularity is usefull for packages that have a lifetime that differs from the core operating system packages
- RHEL 9 offers 2 main repositories:
    - BaseOS has core OS content for RHEL. Packages in BaseOS share the OS lifecycle
    - AppStream is used for packages that don't have the same lifecycle as RHEL

### Understanding AppStream Packages
- AppStream packages are offered as individual packages or as modules
- In RHEL 9.0 no modules are provided by default, they may be offered separately later
- In a module, different streams can be offered, where each package version has its own stream
- Module profiles provide common installation patterns, such as server, client and more

## 12.6 Managing dnf Updates and History
- All transactions that `dnf` perform are logged to `/var/log/dnf.rpm.log`
- Use `dnf history` for a summary of all installation and removal transactions
- Use `dnf history undo n` to undo sepcific transaction

### Understanding Subscription Manager
- To use RHEL, you need to register the system and attach a subscription
    - Before completing this procedure, you'll have no repository access
- To register, use `subscription-manager register`
    - You'll be prompted for the username of the user account to which the subscription is connected
- To attach a subscription, use `subscription-manager attach --auto`
- To unregister a system use `subscription-manager unregister`

### Understanding Entitlement Certificates
- After attaching subscriptions to a system, entitlement certificates are created
    - `/etc/pki/product` indicates the installed Red Hat products
    - `/etc/pki/consumer` identifies the Red Hat account for registration
    - `/etc/pki/entitlement` indicates which subscription is attached
- Use the `rct` command to check current entitlements
    - `rct cat-cert /etc/pki/entitlement/abcabc.pem`

## Lesson 12 Lab: Managing Software
- Ensure your system is using a repository for base packages as well as application streams
- Find the package that contains the seinfo program file and install it
- Download the httpd package from the repositories without installing it, and query to see if there are any scripts in it