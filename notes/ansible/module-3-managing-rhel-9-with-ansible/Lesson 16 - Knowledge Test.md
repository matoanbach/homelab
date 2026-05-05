# 16.1 Before you Start: Essential Tips
- All Ansible documentation is available on the exam. Make sure you practice finding the appropriate documentation; it sometimes is well hidden.
- You don't have to use `ansible-navigator`. All assignments can also be done through `ansible-playbook` and other older tools.
- According to Red Hat exam philosophy, it doesn't matter how you do it, as long as you're doing the right thing.
- Avoid non-idempotent behavior as much as you can
- You think better behind your coffe machine. During the exam you may have 3 breaks, use them!
- Read the "essential information" section very carefully; it has essential information.
- Make suer you are very comfortable with the following:
  - Using roles, collections, and requirements files
  - Using conditionals
  - Using block and rescue
- All tasks expect you to create a working solution. If needed, install packages, create users, start services, and more to ensure the playbook solution will work.

# 16.2 Setting up the Environment
## Task 1: Setting up the Environment
- To work through the assignments in this exam, you need the following:
  - 3 virtual machines running either RHEL 9 or CentOS Stream:
    - A control host
    - A node1 host
    - A node2 host
- Add a second disk to node1, not node2
- Install with GUI on the control host and use the minimal installation pattern on the other nodes
- If running RHEL 9, make sure your control host is (manually) registered using subscription manager.
- Ensure that the httpd package is copied to the control host while installing (or after installation)

## Task 1: Solution
```yml
sudo subscription-manager register
sudo subscription-manager attach
sudo dnf repolist
vim /etc/hosts
# add the below to /etc/hosts
192.168.29.199 control.example.com control
192.168.29.191 ansible1.example.com ansible1
192.168.29.192 ansible2.example.com ansible2
# exit /etc/hosts
ssh ansible1
ssh ansible2
```

# 16.3 Configuring the Control Node
## Task 2: Configuring the Control Node
- Install the Ansible software on the control node
- Create a user ansible on all nodes, and ensure that:
  - Use ansible has sudo privileges on all nodes
  - Use ansible can remote login using SSH keys
- Create an inventory file that meets the following requirements:
  - A host group with the name dev is created, and node1 is a member of this group
  - A host group with the name prod is created, and node2 is a member of this group
  - A host group with the name servers is created, and has the groups prod and dev as its members
- In control host user ansible homedirectory, create an ansible.cfg that meets the following requirements:
  - It refers to the inventory file in the current directory
  - privilege escalation is defined. The mechanism is sudo, no passwords should be asked
  - The default location for collections is the directory colections in the user ansible home directory.
  - The default location for roles is the directory roles in the user ansible home directory.

## Task 2: Solution
```yml
sudo subscription-manager repos --enable=rhel-9-for-x86_64-appstream.rpms
sudo dnf repolist
sudo subscription-manager repos --enable=ansible-automation-platform-2.2-for-rhel-9-x86_64-rpms
sudo dnf install ansible-core ansible-navigator -y
sudo dnf install httpd -y
ansible --version
```

```yml
sudo useradd ansible
sudo passwd ansible
su - ansible
vim inventory
# edit inventory
[dev]
ansible1

[prod]
ansible2

[servers:children]
prod
dev
# exit inventory

ansible -i inventory all -u student -k -b -K -m user -a "name=ansible"
ssh ansible1
ssh ansible2
ansible -i inventory all -u student -k -b -K -m shell -a "echo passwd | passwd --stdin ansible" 

ssh-keygen
for i in ansible1 ansible2; do ssh-copy-id $i; done
```

```yml
ansible -i inventory all -m command -a "whoami"
ansible -i inventory all -u student -k -b -K -m copy -a "content='ansible ALL=(ALL) NOPASSWD: ALL' dest=/etc/sudoers.d/ansible"
ansible -i inventory all -b -a "ls -l /root"
sudo vim /etc/ansible/ansible.cfg
vim ansible.cfg
# edit ansible.cfg
[defaults]
inventory = inventory
remote_user = ansible
ask_pass = false
collections_path = collections:/usr/share/ansible/collections
roles_path = roles:/usr/share/ansible/roles:/etc/ansible/roles

[privilege_escalation]
become = true
become_method = sudo
become_user = root
become_ask_pass = false
# exit ansible.cfg
```

# 16.4 Setting up a Repository Server
## Task 3: Setting up a Repository Server
- Configure the control node to host the contents of the RHEL 9 installation
- Ensure the repository content is copoed to /reposerver/BaseOS and /reposerver/AppStream
- Provide the contents of these two directories as symbolic links in the Apache server documentroot (/var/www/html)
- Ensure that the Apache server is installed and started automatically, and is available through the firewall.

## Task 3: Solution
### setup_repo.yml
```yml
---
- name: install apache to export repo
  hosts: localhost
  tasks:
  - name: install apache server
    yum:
        name: 
        - httpd
        - policycoreutils-python-utils
        state: latest
  - name: start apache server
    service:
        name: httpd
        state: started
        enabled: yes
  - name: open firewall
    firewalld:
        service: http
        state: enabled
        permanent: true

- name: setup the repo directory
  hosts: localhost
  tasks:
  - name: create /reposerver
    file:
        path: /reposerver
        state: directory
  - name: make links to repo directories
    file:
        src: /reposerver
        dest: /var/www/html/reposerver
        state: link
  - debug:
        msg: you need to manually copy content from the installation iso to /reposerver/
  - name: setup selinux context
    sefcontext:
        target: '/reposerver(/.*)?'
        setype: httpd_sys_content_t
        state: present
  - name: run restorecon
    command: restorecon -Rv /reposerver
```

```bash
ansible-playbook setup_repo.yml -e ansible_python_interpreter=/usr/bin/python
```

## Mounting locally
```bash
mount /dev/sr0 /mnt
sudo cp -R  /mnt/[AB]/* /reposerver/
systemctl restart httpd
curl localhost:/reposerver
```


# 16.5 Setting up Repository Clients
## Task 4: Setting up Repository
- Configure all nodes as repository clients to the repository server that was configured in the previous task

## Task 4: Solution
```yml
---
- name: setup repo clients
  hosts: all
  tasks:
  - name: setting up custom repos
    yum_repository:
        name: installdisk
        description: local control repos 
        file: installdisk
        baseurl: https://control.example.local/reposerver
        gpgcheck: no
```

## Task 4: testing solution
```bash
ansible all -a "yum repolist"
```
# 16.6 Installing Collections
## Task 5: Installing Collections
- Use a requirements.yml file to install the following collections:
  - community.general
  - ansible.posix

## Task 5: Solution
```yml
collections:
    - community.general
    - ansible.posix
```
# 16.7 Generating an /etc/hosts file
## Task 6: Generating an /etc/hosts File
- Use an automated solution to create the contents of the /etc/hosts file on all managed hosts based on information that was found from the inventory.

## Task 6: Solution
### hosts.j2
```yml
{% for host in groups['all'] %}
{{ hostvars[host]['ansible_facts']['default_ipv4']['address']}} {{ hostvars[host]['ansible_facts']['fqdn'] }} {{ hostvars[host]['ansible_facts']['hostname'] }}
{% endfor %}

```

### task-6.yml
```yml
---
- name: create hosts file
  hosts: all
  tasks:
  - name: using template
    template:
        src: hosts.j2
        dest: /etc/hosts
```

# 16.8 Creating a Vault Encrypted File
## Task 7: Creating a Vault Encrypted File
- Encrypt the file task7file.yml with ansible vault, using the password "mypassword"
- Store this password in the file vaultpass.txt in the current project directory.
- Ensure that the decrypted contents of the file can be shown using a vault password file

## Task 7: Solution
### task7file.yml
```yml
users:
    - username: anna
      pwd: secretpass
      grp: profs
    - username: anouk
      pwd: password
      grp: students
    - username: lisa
      pwd: verysecretpass
      grp: profs
    - username: linda
      pwd: notsosecretpass
      grp: students
```

```bash
ansible-vault encrypt task7file.yml
echo mypassword > vaultpass.txt
```

# 16.9 Creating Users
# 16.10 Creating a Role
# 16.11 Creating a Cron Job
# 16.12 Creating a Logical Volume
# 16.13 Generating a Report