# 3.1 Exploring Modules and Content Collections
- In ansible 2.9 and ealier, thousands of modules were provided
- Since ansible 2.10, only essential modules are provided in the ansible-core package
- Additional modules are provided through content collections
- By organizing modules in content collections, responsibility for module development can be delegated to specific projects and companies
- Additional content collections can be installed from different sources:
  - Ansible Galaxy at https://galaxy.ansible.com
  - Ansible Automation Platform
  - Directly from tar archives

## ansible-navigator and Modules
- **ansible-navigator** gets modules from content collections using its container-based execution environments
- Using an execution environment means that you don't have to set up an Ansible control host, but just run required content from the execution environment.

## Using ansible-navigator Execution Environments
- To access RHEL-provided execution environments, first use a valid Red Hat account to log in to registry.redhat.io: `podman login registry.redhat.io`
- Next, use `ansible-navigator` images to download the execution environment container images, this will show the `ee-supported-rhel8` image (or a later version if that is available)
- Press Esc to exit the image list

## Understanding Module Names
- Modules that are provided through collections have a Full Qualified Collection Name (FQCN):
  - `ansible.builtin.service`
  - `ansible.posix.firewalld`
- Using an FQCN is recommended, as duplicate names may occur between different collections
- If no duplicate names occur, you may use short module names instead

# 3.2 Learning How to Use Modules
## Getting Help about Modules
- `ansible-doc` provides documentation about all aspects of Ansible
- Different types of items are documented, see `ansible-doc --help` for an overview
- If no type is specified, the module is used as the default type
- To get a list of available modules, use `ansible-doc -l`
- To show usage information about a specific item, use `ansible-doc [-t itemtype] item` 

## Getting Help with ansible-navigator
- `ansible-navigator` can also provide help about items
- `ansible-navigator doc -m stdout ansible.core.ping` provides help about the ping module
- Use `ansible-navigator --pp never` to tell navigator to never look for a newer container image
- You may find using `ansible-doc` faster

## History commands:
```bash
   21  podman login registry.redhat.io
   22  ansible-navigator images
   23  clear
   24  ansible-doc -t shell
   25  ansible-doc -l
   26  ansible-doc --help
   27  ansible-doc -t shell -l
   28  man ansible-doc
   29  ansible-doc -t filter password_hash
   30  ansible-doc -t keyword delegate_to
   31  ansible-doc user
   32  clear
   33  ansible-doc user
   34  ansible-doc ansible.posix.firewalld
   35  ansible-doc firewalld
   36  ansible-navigator doc -m stdout 
   37  ansible-navigator doc -m stdout ansible.core.ping
   38  ansible-navigator --pp never doc -m stdout ansible.core.ping
   39  ansible-navigator --pp never doc -m stdout user
   40  clear
   41  ansible-navigator --pp never doc -m stdout user
   42  ansible-navigator --pp never doc  user
```

# 3.3 Installing Content Collections
## Collections
- Regardless of whether you're using just Ansible Core, or `ansible-navigator` in AAP, you'll always have access to one content collection: `ansible.builtin`
- To get access to more collections, you may want to define and use a custom execution environment (which is not a part of the EX294 objectives)
- Collections are provided through Ansible Galaxy or Ansible Automation Platform 

## Installing collections
- Use `ansible-galaxy collection install my.collection -p collections` to install new collections
- While installing collections, use the `-p collections` option to tell the execution environment in which directory the collection is available.
- Without the `-p path` option, the collection is installed in the default `collections_path`, which is `~/.ansible/collections:/usr/share/ansible/collections`
- This default `collections_path` works with the `ansible` and `ansible-playbook` commands, but is not available from within the `ansible-navigator` execution environment
- Using the `-p collections` option, ensures that the collection will always be found, as this directory will always be search first, even if not specified in the `collections_path` 

## Installing Collections from Different Locations
- Collection can be installed from different locations:
  - Form Galaxy: Use `ansible-galaxy collection install my.collection -p collections`
  - From a tar ball: Use `ansible-galaxy collection install /my/collection.tar.gz -p collections`
  - From a URL: Use `ansible-galaxy collection install https://my.example.local/my.collection.tar.gz -p collections`
  - From Git: Use `ansible-galaxy collection install git@git.example.local:mygitaccount/mycollection.git -p collections` 

## Demo: Using Collections:
- `ansible-galaxy collection install community.crypto -p collections`
    ```bash
    [ansible@control ~]$ ansible-galaxy collection install community.crypto -p collections
    Starting galaxy collection install process
    [WARNING]: The specified collections path '/home/ansible/collections' is not part of the configured Ansible
    collections paths '/home/ansible/.ansible/collections:/usr/share/ansible/collections'. The installed collection
    will not be picked up in an Ansible run, unless within a playbook-adjacent collections directory.
    Process install dependency map
    Starting collection install process
    Downloading https://galaxy.ansible.com/api/v3/plugin/ansible/content/published/collections/artifacts/community-crypto-3.0.3.tar.gz to /home/ansible/.ansible/tmp/ansible-local-39963alaa9o6g/tmpv132m9s4/community-crypto-3.0.3-r3wgtn99
    Installing 'community.crypto:3.0.3' to '/home/ansible/collections/ansible_collections/community/crypto'
    community.crypto:3.0.3 was installed successfully
    [ansible@control ~]$ 
    ```
- `ansible-galaxy collection list`
- `ansible-navigator`
  - `:collections`
- Edit ansible.cfg to include the following
  - `collections_path=./collections`
- `ansible-galaxy collection list`
- Change the ansible.cfg collection path to the following
  - `collections_path=./collections:~/.ansible/collections:/usr/share/ansible/collections`
- `ansible-galaxy collection list`

# 3.4 Using requirements.yml
## collections/requirements.yml
- A requirements.yml can be provided in the current project directory to list all collections that are needed in the project
- It lists all required collections, and installs them using `ansible-galaxy collections install -r collections/requirements.yml -p collections`
- Don't forget the `-p collections` option, or else the collection won't be found by `ansible-navigator`

## Example collections/requirements.yml
```yaml
collections:
    - name: community.aws
    - name: ansible.posix
        version: 1.2.1
    - name: /tmp/my-collection.tar.gz
    - name: https://www.example.local/my-collection.tar.gz
    - name: git+https://github.com/ansible-collections/community.general.git
        version: main
```

# 3.5 ansible-navigator
## Using Collections in Navigator
- The `ee-supported-rhel8` default execution environment comes with a set of common collections
- From `ansible-navigator`, use `:collections` to show collections that are currently available
- To install collections and make them available in `ansible-navigator`, use `ansible-galaxy collection install -p collections` as described before.


# 3.6 Exploring Essential Modules
## Essential Modules
- `ansible.builtin.ping`: verifies host availability
  - `ansible all -m ping`
- `ansible.builtin.service`: checks if a service is currently running
  - `ansible all -m service -a "name=httpd state=started"`
- `ansible.builtin.command`: runs any command, but not through a shell
  - `ansible all -m command -a "/sbin/reboot -t now"`
- `ansible.builtin.shell`: run arbitrary commands through a shell
  - `ansible all -m shell -a set`
- `ansible.builtin.raw`: runs a command on a remote host without a need for python
- `ansible.builtin.copy`: copies a file to the managed host
  - `ansible all -m copy -a 'content="hello world" dest=/etc/motd'`

# 3.7 Idempotency
- Idempotency in Ansible means that no matter the current state of the managed node, running an Ansible module should always give the same result
- The result is that the desired state as expressed by the module should be implemented
- If the currentstate already matches the desired state, nothing should happen
- Most important: if the current state already matches the desired state, the Ansible module should not generate an error message
- In Ansible you should always configure idempotent solutions
- Some modules - including `command` however are not idempotent

## Demo: Exploring Idempotency
- `ansible ansible1 -m command -a "useradd lisa"`
- `ansible ansible1 -m command -a "useradd lisa"`
- `ansible ansible1 -m user -a "name=linda"`
- `ansible ansible1 -m user -a "name=linda"`

# 3.8 Using docs.ansible.com
- Ansible documentation is provided on docs.ansible.com
- It may be a bit hard to find what you need, as the documentation is focused on Automation Platform
- The best resource for documentation about Ansible Core is under the Core button on this website

# Lesson 3 Lab: Working with Modules
- Install the community.cryto collection in such a way that it can be used by `ansible-navigator`, as well as the `ansible` command
- Use the `ping` module in an ad hoc command to verify that all of your hosts have been set up successfully
    ```bash
    [ansible@control ~]$ ansible all -m ping
    ansible1 | SUCCESS => {
        "ansible_facts": {
            "discovered_interpreter_python": "/usr/bin/python3"
        },
        "changed": false,
        "ping": "pong"
    }
    ansible2 | SUCCESS => {
        "ansible_facts": {
            "discovered_interpreter_python": "/usr/bin/python3"
        },
        "changed": false,
        "ping": "pong"
    }
    ```
- Use the appropriate ad hoc command to run the `grep ssh` command on the output of the `rpm -qa` command on all managed hosts

    ```bash
    [ansible@control ~]$ ansible all -m shell -a "rpm -qa | grep ssh"
    ansible1 | CHANGED | rc=0 >>
    libssh-config-0.9.6-3.el9.noarch
    libssh-0.9.6-3.el9.x86_64
    openssh-8.7p1-8.el9.x86_64
    openssh-clients-8.7p1-8.el9.x86_64
    openssh-server-8.7p1-8.el9.x86_64
    ansible2 | CHANGED | rc=0 >>
    libssh-config-0.9.6-3.el9.noarch
    libssh-0.9.6-3.el9.x86_64
    openssh-8.7p1-8.el9.x86_64
    openssh-clients-8.7p1-8.el9.x86_64
    openssh-server-8.7p1-8.el9.x86_64
    ```