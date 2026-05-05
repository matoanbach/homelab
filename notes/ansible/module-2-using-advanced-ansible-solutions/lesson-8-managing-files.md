# 8.1 Modifying Files

- Different Modules are available for managing files
  - `ansible.builtin.lineinfile`: ensures that a line is in a file, useful for changing a single line in a file
  - `ansible.builtin.blockinfile`: manipulates multi-like blocks of text in files
  - `ansible.builtin.file`: sets attributes to files, and can also create and remove files, symbolic links and more
  - `ansible.builtin.stat`: used to request file statistics. Useful when combined with register

## file.yml
```yaml
---
- name: create a file
  hosts: all
  tasks:
    - name: create a file
      file:
        path: /tmp/removeme
        owner: ansible
        mode: 0640
        state: touch
        setype: public_content_rw_t
```

## addcustomfacts.yml
```yml
---
- hosts: ansible1
  gather_facts: no
  tasks:
    - name: Create a custom fact on ansible1
      blockinfile:
        path: /etc/ansible/facts.d/local.fact
        create: true
        block: |
          [localfacts]
          type: production
- hosts: ansible2
  tasks:
    - name: Create custom fact on ansible2
      blockinfile:
        path: /etc/ansible/facts.d/local.fact
        create: true
        block: |
          [localfacts]
          type: testing
```

# 8.2 Copying Files to and From Managed Hosts

- Different Modules are available for managing files
  - `ansible.builtin.copy`: copies a file from a local machine to a location on a managed host
  - `ansible.builtin.fetch`: used to fetch a file from a remote machine and store in on the management node
  - `ansible.posix.synchronize`: synchronizes files `rsync` style. Only works if the linux `rsync` utility is available on managed hosts
  - `ansible.posix.patch`: applies patches to files

## copy.yml
```yml
---
- name: file copy modules
  hosts: all
  tasks:
  - name: copy file demo
    copy:
      src: /etc/hosts
      dest: /tmp/
  - name: add some lines to /tmp/hosts
    blockinfile:
      path: /tmp/hosts
      block: |
        192.168.4.111 host111.example.com
        192.168.4.112 host112.example.com
      state: present
  - name: verify file checksum
    stat:
      path: /tmp/hosts
      checksum_algorithm: md5
    register: result
  - debug:
      msg: "The checksum of /tmp/hosts is {{ result.stat.checksum }}"
  - name: fetch a file
    fetch:
      src: /tmp/hosts
      dest: /tmp/
```

# 8.3 Using Jinja2 Templates

- `lineinfile` and `blockinfile` can be used to apply simple modifications to files
- For more advanced modifications, use Jinja2 templates
- Jinja2 is a templating engine for Python
- In a Jinja2 template, variables can be used that are defined in the playbook
- The `ansible.builtin.template` module renders the Jinja2 template to a final configuration file
- Best practice: use Jinja2 templates if you need to generate files with different variables-based content on managed hosts. For simple modifications, use lineinfile and blockinfile

## Marking Managed Files
- To prevent administrators from overwriting files that are managed by Ansible, set the `ansible_managed` string
  - First, in ansible.cfg set `ansible_managed = # Ansible managed`
  - On top of the Jinja2 template, include the following line: `# {{ ansible_managed }}`
- In the `ansible_managed` string, different variables can be used:
  - `ansible_managed = {file} modified by Ansible on %d-%m-%Y by {uid}`

## vsftpd-template.conf
```yaml
---
- name: configure VSFTPD using a template
  hosts: all
  vars:
    anonymous_enable: yes
    local_enable: yes
    write_enable: yes
    anon_upload_enable: yes
  tasks:
  - name: install vsftpd
    yum:
      name: vsftpd
  - name: use template to copy FTP config
    template:
      src: vsftpd.j2
      dest: /etc/vsftpd/vsftpd.conf
```

## ansible.cfg
```conf
[defaults]
inventory = inventory
remote_user = ansible
collections_path = /home/ansible/collections:/home/ansible/.ansible/collections:/usr/share/ansible/collections
ansible_managed = {file} modified by Ansilbe on %d-%m-%Y by {uid}

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False 
```

# 8.4 Applying Conditionals in Jinja2 Templates
## Using for Statements
- Jinja2 templates can loop over the value of a variable using a for statement

```yaml
{% for user in users %}
    {{user}}
{% endfor %}

{% for host in groups['webservers'] %}
    {{host}}
{% endfor %}
```

## hostsfile.yml
```yaml
---
- name: update /etc/hosts file dynamically
  hosts: all
  tasks:
    - name: update /etc/hosts
      template:
        src: templates/hosts.j2
        dest: /etc/hosts
```

## templates/hosts.j2
```conf
{% for host in groups['all']  %}
{{ hostvars[host]['ansible_facts']['default_ipv4']['address'] }} {{ hostvars[host]['ansible_facts']['fqdn'] }} {{ hostvars[host]['ansible_facts']['hostname'] }}
{% endfor %}
```

# 8.5 Managing SELinux File Context

- `ansible.builtin.file`: sets attributes to files, including SELinux
- `community.general.sefcontext`: manages SELinux file context in the SELinux Policy (but not on files)
- `ansible.builtin.command`: required to run `restorecon` after `sefcontext`
- Notice that `file` sets SELinux context directly on the file (like the `chcon` command), and not in the policy. DO NOT USE!
- Also consider using the RHEL system role for managing SELinux

## selinux.yml
```yml
---
- name: show selinux
  hosts: all
  tasks:
  - name: install required packages
    yum:
      name: policycoreutils-python-utils
      state: present
  - name: set selinux context
    sefcontext:
      target: /tmp/removeme
      setype: public_content_rw_t
      state: present
    notify:
      - run restorecon
  handlers:
  - name: run restorecon
    command: restorecon -v /tmp/removeme
```

# Lesson 8 Lab: Applying Conditionals in Templates
- Create a playbook that sets the hostnames of the managed hosts to the names that are used in the inventory
- Reboot the managed hosts after setting the hostnames

```yml
---
- name: set hostname to {{ inventory_hostname }}
  hosts: all
  tasks:
    - name: set the hostname
      command: hostnamectl set-hostname {{ inventory_name }}
    - name: reboot
      reboot:
        msg: rebooting...
```