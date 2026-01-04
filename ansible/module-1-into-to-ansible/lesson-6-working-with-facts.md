# 6.1 Understanding Facts

- Ansible Facts are variables that are automatically set and discovered by Ansible on managed hosts
- Facts contain information about hosts that can be used in conditionals
  - Available memory
  - IP Address
  - Distribution and distribution family
  - and much more
- Using facts allows you to perform actions only if certain conditions are true

## Managin Fact Gathering
- By default, all playbooks perform fact gathering before running the actual plays
- Use `gather_facts: no` in play header to disable
- Even if fact gathering is disabled, it can be enabled again by running the `setup` module in a task
- You can run fact gathering in an ad hoc command using the `setup` module
- To show facts, use the debug module to print the value of the `ansible_facts` variable
- Notice that in facts, a hierarchical relation is show where you can use the dotted format to refer to a specific fact.

## Troubleshooting Slow Fact Collection
- If fact collection is slow because you're working against lots of hosts, you can use a fact cache
- If you're experiencing slow fact gathering, ensure that host name resolution is set upp on all hosts
- Ensure that each managed host has an `/etc/hosts` file that allows for name resolution between all managed hosts

# 6.2 Using Multi-tier Variables

- In Ansible 2.4 and before, Ansible facts were stored as individual variables, such as `ansible_hostname` and `ansible_interfaces`, containing different sub-variables stored in a dictionary
- To refer to the next-tier variables, dots were used as a separator: `ansible_date_time.date`
- In Ansible 2.5 and later, all facts are sotred in one dictionary variable with the name `ansible_facts` , and referring to specific facts happens in a differnt way: `ansible_facts[hostname]`

```yaml
ansible_date_time.date
ansible_facts.date_time.date
ansible_facts['date_time']['date']
```

```yaml
---
- name: show facts
  hosts: all
  gather_facts: yes
  tasks:
  - name: old notation
    debug:
      msg:  facts - {{ ansible_facts.all_ipv4_addresses[0] }}
  - name: preferred notation
    debug:
      msg: this is the preferred notation {{ ansible_facts['default_ipv4']['address'] }}
  - name: this will not work
    debug:
      msg: the IP address is {{ ansible_facts.ansible_default_ipv4.address }}
```
# 6.3 Understanding Dictionaries and Arrays
- Multi-valued variables can be used in playbooks and can be seen in output, such as Ansible facts
- When using a multi-valued variable, it can be written as an array (list), or as a dictionary (hash)
- Each of these has their own specific use cases
  - Dictionaries are used in Ansible facts
  - Arrays are common for multi-valued variables, and easily support loops
  - Loops are not supported on dictionaries

## Dictionaries versus Arrays
- Dictionaries and arrays in Ansible are based on Python dictionaries and arrays
- An array (list) is an ordered list of values, where each value can be addressed individually
```python
List = ["one", "two", "three"]
print(List[0])
```
- A dictionary (hash) is an unordered collection of values, which is stored as a key-value pair
```python
Dict = {1: "one", 2: "two", 3: "three"}
print(Dict)
```
- Notice that a dictionary can be included in a list, and a list can be a part of a dictionary

## Dictionary (Hash)
- Dictionaries can be written in two ways:
```yaml
users:
    linda:
        username: linda
        shell: /bin/bash
    lisa:
        username: lisa
        shell: /bin/sh
```

- Or as:
```yaml
users:
    linda: { username: "linda", shell: "/bin/bash" }
    lisa: { username: "lisa", shell: "/bin/bash" }
```

## Using Dictionary
- To address items in a dictionary, you can use two notations:
  - variable_name["key"], as in `users['linda']['shell']`
  - variable_name.key, as in `users.linda.shell`
- Dictionaries are used in facts, use arrays in conditionals

## Using Array (List)
- Arrays provide a list of items, where each item can be addressed separately
```yaml
users:
    - username: linda
      shell: /bin/bash
    - username: lisa
      shell: /bin/sh
```
- Individual items in the array can be addressed, using the `{{ var_name[0] }}` notation
- Use arrays for looping, not dictionaries
- To access all variables, you can use `with_items` or `loop` (covered in the next lesson)

## Recognizing Arrays and Dictionaries
- In output like facts, a list is always written between `[]`
- Dictionaries are written between `{}`
- And if the output is just showing `" "`, it is a string
- Check `ansible_mounts` in the facts, which actually presents a list of dictionaries

# 6.4 Defining Custom Facts
- Host (inventory) variables exist on the control machine and the host itself doesn't know about them
- Custom facts allow administrators to dynamically generate variables which are on the host stored as facts
- custom facts are stored in an ini or json file in the `/etc/ansible/facts.d` directory on the managed host
  - The name of these files must end in `.fact`
  - Custom facts must have a [label] to help identify the variables

## Using Custom Facts
- Custom facts are stored in the `ansible_facts.ansible_local` variable
- Use `ansible hostname -m setup -a "filter=ansible_local"` to display local facts
- Notice how fact filename and label are used in the fact
- To refer to custom facts, use `ansible_facts.ansible_local`, not `ansible_facts.local`

# 6.5 Understanding Variables
- Variables set in a playbook only exist in the specific play where they are defined
- Variables can get a playbook scope by defining them as follows:
  - Through host or host group
  - In inventory
  - By var plugins
  - Using modules like `set_fact` and `include_vars`
- Inventory and host [group] variables have a host scope. This also goes for the `hostvars[]` dictionary
- Use `-e "var=name"` to define a variable with a playbook scope that overrides all other variables

## Variable Precedence
- More specific will always win, Ansible will give precedence to variables that were defined more recently, more actively, or with more explicit scope
- Below is a partial list of precedence, from lowest to highest
  - role defaults
  - inventory variables
  - host facts
  - play variables
  - included play variables
  - task variables
  - variables provided on the command line

# Lab 6: Wokring with Facts
- Create a playbook that sets a local fact `type = production` on host ansible1
- Use an ad-hoc command with a filter to check that the fact was created successfully

```yaml
---
- name: playbook for lab6
  hosts: ansible1
  vars:
    remote_dir: /etc/ansible/facts.d
    facts_file: lab6.fact
  tasks:
    - name: create a fact dir
      file:
        state: directory
        recurse: true
        path: "{{ remote_dir }}"
    - name: copy facts over
      copy:
        dest: "{{ remote_dir }}"
        src: "{{ facts_file }}"
      register: task_result
    - name: print status
      debug:
        msg: >
          {{ task_result }}

---
- name: playbook for lab6
  hosts: ansible1
  vars:
    remote_dir: /etc/ansible/facts.d
    facts_file: lab6.fact
  tasks:
    - name: create a fact dir
      file:
        state: directory
        recurse: true
        path: "{{ remote_dir }}"
    - name: copy facts over
      copy:
        dest: "{{ remote_dir }}"
        content: |
          [facts]
          type=production
```



- Result:
```yaml
[ansible@control rhce_clone]$ ansible-playbook lab-6.yml 

PLAY [playbook for lab6] ***************************************************************************************

TASK [Gathering Facts] *****************************************************************************************
ok: [ansible1]

TASK [create a fact dir] ***************************************************************************************
ok: [ansible1]

TASK [copy facts over] *****************************************************************************************
ok: [ansible1]

TASK [print status] ********************************************************************************************
ok: [ansible1] => {
    "msg": {
        "changed": false,
        "checksum": "03e8170f09069a662a6125e7604f7e1430f0cf0a",
        "dest": "/etc/ansible/facts.d/lab6.fact",
        "diff": {
            "after": {
                "path": "/etc/ansible/facts.d/lab6.fact"
            },
            "before": {
                "path": "/etc/ansible/facts.d/lab6.fact"
            }
        },
        "failed": false,
        "gid": 0,
        "group": "root",
        "mode": "0644",
        "owner": "root",
        "path": "/etc/ansible/facts.d/lab6.fact",
        "secontext": "system_u:object_r:etc_t:s0",
        "size": 25,
        "state": "file",
        "uid": 0
    }
}

PLAY RECAP *****************************************************************************************************
ansible1                   : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[ansible@control rhce_clone]$ ansible ansible1 -m setup -a "filter=ansible_local"
ansible1 | SUCCESS => {
    "ansible_facts": {
        "ansible_local": {
            "lab6": {
                "lab6": {
                    "type": "production"
                }
            }
        },
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false
}
```