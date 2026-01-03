# 5.1 Understanding Variables
- A variable is a label that is assigned to a specific value to make it easy to refer to that value throughout the playbook
- Variables can be defined by administrators at different levels
- A fact is a special type of variable, that refers to a current state of an Ansible-managed system
- Variables are pariticularly useful when dealing with managed hosts where specifics are different
    - Set a variable `web_service` on Ubuntu and Red Hat
    - Refer to the variable `web_service` instead of the specific service name

## Defining Variables
- In Ansible, different types of variables can be used and defined
- Variables can be defined in playbooks
- Alternatively, include files can be used
- Variables can be specifiied as command line arguments
- The output of a command or task can be used in a variable using `register`
- `vars_prompt` can be used to ask for input and store that as a variable
- `ansible-vault` is used to encrypt sensitive values
- Facts are discovered host properties stored as variables
- Host variables are host properties that don't have to be discovered
- System variables are a part of the Ansible system and cannot be changed

## Variable Precedence
- Variables can be set with different types of scope
  - Global Scope: this is when a variable is set from inventory or the command line
  - Play Scope: this is applied when it is set from a play
  - Host Scope: this is applied when set in inventory or using a host variable inclusion file
- When the same variable is set at different levels, the most specific level gets precedence
- When a variable is set from the command line, it has highest precedence
  - `ansible-playbook site.yml -e "web_package=apache"`

# 5.2 Using Variables in Playbooks
- Variables can be defined in a vars section in the beginning of a play
    ```yaml
    - hosts: all
      vars:
        web_package: httpd
    ```
- Alternatively, variables can be defined in a variable file, which will be included from the playbook
    ```yaml
    - hosts: all
      vars_files:
        - vars/users.yml
    ```
## Using Variables
- After defining the variables, they can be used later in the playbook
- Refer to a variable `{{ web_package }}`
- In conditional statements (discussed later), no curly braces are needed to refer to variable values
  - `when: 'not found' in command_result.err`
    ```yaml
    {% if ansible_facts['devices']['sdb'] is defined %} 
        Secondary disk size: {{
            ansible_facts['devices']['sdb']['size'] }}
    ```
- If the variable is the first element, using quotes is mandatory: `"{{ web_package }}"`

# 5.3 Including Variables
## Includes
- While writing playbooks, it is good practice not to include site specific data in the playbooks
- Playbooks that define variables within the playbook are less portable
- To make variables more flexible, they should be included in the play header using `vars_files`
- See `ansible-doc -t keyword vars_files` for a short description
- The variables file itself contains variable defintions as `key: value`

# 5.4 Managing Host Variables
- Host variables are specific to a host only
- They are defined in a YAML file that has the name of the inventory hostname and are stored in the `host_vars` directory in the current project directory
- To apply variables to host groups, a file with the inventory name of the host group should be defined in the `group_vars` directory in the current project directory
- Host variables defined this way will be picked up by the hosts automatically
- Host variables can also be set in the inventory, but this is now deprecated

```txt
[ansible@control rhce_clone]$ tree -R  .
.
├── \
├── 5-2.yml
├── 5-3.yml
├── 5-4.yml
├── ansible.cfg
├── group_vars
│   └── webservers
├── host_vars
│   └── ansible1
├── inventory
├── lab4-undo.yml
├── lab4.yml
└── vars
    └── users
```

# 5.6 Using Register to Set Variables
- Some variables are built in and cannot be used for anything else
    - `hostvars`: a dictionary that contains all variables that apply to a specific
    - `inventory_hostname`: inventory name of the current host
    - `inventory_host_name`: short host inventory name
    - `groups`: all hosts in inventory, and groups these hosts belong to
    - `group_name`: list of groups the current host is a part of
    - `ansible_check_mode`: boolean that indicates if play is in check mode
    - `ansible_play_batch`: active hosts in the current play
    - `ansible_play_hosts`: same as ansible_play_batch
    - `ansible_version`: current Ansible version

```yaml
[ansible@control rhce_clone]$ cat 5-6.yml 
---
- name: variable files
  hosts: ansible1
  tasks:
  - name: create a user 
    user:
      name: "{{ user }}"
    register: task_result
  - name: debug users
    debug:
      var: task_result
```

# 5.7 Using Vault to Manage Sensitive Values
```yaml
---
- name: variable files
  hosts: ansible1
  tasks:
  - name: debug users
    debug:
      msg: the user is {{ user }}  the password is {{ pwhash }}
  - name: create a  user {{ user }}
    user:
      name: "{{ user }}"
  - name: set password
    shell: echo {{ pwhash }} | passwd --stdin {{ user }} 
    register: set_password_result
  - name: debug set password
    debug:
      var: set_password_result
```
- result:
```bash
[ansible@control rhce_clone]$ ansible-playbook --ask-vault-password 5-7.yml
Vault password: 

PLAY [variable files] ******************************************************************************************

TASK [Gathering Facts] *****************************************************************************************
ok: [ansible1]

TASK [debug users] *********************************************************************************************
ok: [ansible1] => {
    "msg": "the user is linda  the password is password"
}

TASK [create a  user linda] ************************************************************************************
ok: [ansible1]

TASK [set password] ********************************************************************************************
changed: [ansible1]

TASK [debug set password] **************************************************************************************
ok: [ansible1] => {
    "set_password_result": {
        "changed": true,
        "cmd": "echo password | passwd --stdin linda",
        "delta": "0:00:00.111547",
        "end": "2025-08-09 13:50:45.038689",
        "failed": false,
        "msg": "",
        "rc": 0,
        "start": "2025-08-09 13:50:44.927142",
        "stderr": "",
        "stderr_lines": [],
        "stdout": "Changing password for user linda.\npasswd: all authentication tokens updated successfully.",
        "stdout_lines": [
            "Changing password for user linda.",
            "passwd: all authentication tokens updated successfully."
        ]
    }
}

PLAY RECAP *****************************************************************************************************
ansible1                   : ok=5    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```
# Lesson 5 Lab: Using Ansible Vault
- Create a playbook that creates a user. The user as well as the password should come from a variable
- Define both in separate include files
- Make sure the password is encrypted with vault, whereas the username is not encrypted with vault
- Verify it works

```yaml
---
- name: lab5 playbook
  hosts: ansible1
  vars_files:
    - secrets/lab5
    - secrets/secrets
  tasks:
    - name: create a user
      user:
        name: "{{ lab5_user_name }}"

    - name: set password
      shell: echo {{ lab5_user_password }} | passwd --stdin {{ lab5_user_name }}
      register: task_result

    - name: print out the status
      debug:
        var: task_result 
```
- result
```bash
[ansible@control rhce_clone]$ ansible-playbook --ask-vault-password lab-5.yml 
Vault password: 

PLAY [lab5 playbook] *******************************************************************************************

TASK [Gathering Facts] *****************************************************************************************
ok: [ansible1]

TASK [create a user] *******************************************************************************************
changed: [ansible1]

TASK [set password] ********************************************************************************************
changed: [ansible1]

TASK [print out the status] ************************************************************************************
ok: [ansible1] => {
    "task_result": {
        "changed": true,
        "cmd": "echo lab5 | passwd --stdin lab5",
        "delta": "0:00:00.091187",
        "end": "2025-08-09 14:12:01.272124",
        "failed": false,
        "msg": "",
        "rc": 0,
        "start": "2025-08-09 14:12:01.180937",
        "stderr": "",
        "stderr_lines": [],
        "stdout": "Changing password for user lab5.\npasswd: all authentication tokens updated successfully.",
        "stdout_lines": [
            "Changing password for user lab5.",
            "passwd: all authentication tokens updated successfully."
        ]
    }
}

PLAY RECAP *****************************************************************************************************
ansible1                   : ok=4    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  
```