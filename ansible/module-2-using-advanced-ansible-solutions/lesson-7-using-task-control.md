# 7.1 Understanding Conditionals

- `loop`:  allows you to loop over a list of items instead of calling the same task repeatedly
- `when`: performs conditional task execution based on the value of specific variables
- `handlers`: used to perform a task only if triggered by another task that has changed something

# 7.2 Writing Loops
- The `loop` keyword allows you to iterate through a simple list of items
- Before Ansible 2.5, the `with_` keyword was used instead
```yaml
- name: start some services
  service:
    name: "{{ item }}"
    state: started
  loop:
    - vsftpd
    - httpd
```

## Using Dictionaries in Loops
- Each item in a loop can be a hash/dictionary with multiple keys in each hash/dictionary
```yaml
- name: create users using a loop
  hosts: all
  tasks:
  - name: create users
    user:
        name: "{{ item.name }}"
        state: present
        groups: "{{ item.groups }}"
    loop:
        - name: anna
          groups: wheel
        - name: linda
          groups: users
```
## loop versus with_
- The `loop` keyword is the current keyword
- In previous versions of Ansible, the `with_*` keywords were used for the same purpose
- Using `with_X` often is easier, but using plugins and filters offers more options
  - `with_items`: equivalent to the `loop` keyword
  - `with_file`: the `item` contains a file, which content is used to loop through
  - `with_sequence`: generates a list of values based on a numeric sequence
- Loop up "Migrating from with_X to loop" in the Ansible documentation for instructions on how to migrate

# 7.3 Using When
## Example Conditionals
- `ansible_machine == "x86_64"` - Variable contains string value
- `ansible_distribution_version == "8"` - Variable contains string value
- `ansible_memfree_mb == 1024` - Variable value is equal to integer
- `ansible_memfree_mb < 256` - Variable value is smaller than  integer
- `ansible_memfree_mb > 256` - Variable value is bigger than  integer
- `ansible_memfree_mb <= 256` - Variable value is smaller than or equal to integer
- `my_variable is defined` - Variable value exists (nice for facts) 
- `my_variable is not defined` - Variable value does not exist
- `my_variable` - Variable is Boolean true
- `ansible_distribution in supported_distros` - Variable contains another variable

## Variable Types
- String: sequence of characters - the default variable type in Ansible
- Numbers: numeric value, treated as integer or float. When placing a number in quotes it is treated as a string
- Booleans: true/false values (yes/no, y/n, on/off also supported)
- Dates: calendar dates
- Null: undefined variable type
- List or Arrays: a sorted collection of values 
- Dictionary or Hash: a collection of key/value pairs

## Using Filter to Enforce Variable Types
- While working with variable in a when statement, the variable type may be interpreted wrongly
- To ensure that a variable is treated as specific type, filters can be used
  - int (integer) `when vgsize | int > 5`
  - bool (boolean) `when runme | bool`

- Using a filter does not change the variable type, it only changes the way it is interpreted

## Demo on how to use When:
```yml
--
- name: when demo
  hosts: all
  vars:
    supported_distros:
      - Ubuntu
      - CentOS
      - Fedora
  tasks:
    - name: install RH family specific packages
      yum:
        name: "{{ mypackage }}"
        state: present
      when: ansible_distribution in supported_distros
```

# 7.4 Using When and Register to Check Multiple Conditions
## TEsting Multiple Conditions
- `when` can be used to test multiple conditions as well
- Use `and` or `or` and group the conditions with parentheses
```yaml
when: ansible_distribution == "CentOS" or \
ansible_distibution == "RedHat"
when: ansible_machine == "x86_63" and \
ansible_distribution == "CentOS"
```
- The `when` keyword also supports a list and when using a list, all of the conditions must be true
- Complex conditional statements can group conditions using parentheses

```yaml
---
- name: conditionals test 
  hosts: all
  vars:
    package: nmap
  tasks:
  - name: install vsftpd if sufficient space on /boot
    package:
      name: "{{ package }}"
      state: latest
    loop: "{{ ansible_mounts }}"
    when: item.mount == "/boot" and item.size_available > 100000000
```

## Using Register Conditionally
- The `register` keyword is used to store the results of a command or tasks
- Next, `when` can be used to run a task only if a specific result was found

```yaml
- name: show register on random module
    user:
        name: "{{ username }}"
    register: user
- name: show register results
    debug:
        var: user
```

## Another example

```yaml
---
- name: test register
  hosts: all
  vars_prompt:
    - name: username
      prompt: which user are you looking for
      private: no
  tasks:
    - shell: cat /etc/passwd
      register: passwd_contents
    - debug:
        var: passwd_contents
    - debug:
        msg: echo "passwd contains user {{ username }}"
      when: passwd_contents.stdout.find(username) != -1 
```

# 7.5 Conditional Task Execution with Handlers
## Handlers
- Handlers run only if the triggering task has changed something
- By using handlers, you can avoid unnecessary task execution
- In order to run the handler, a `notify` statement is used from the main task
- Handlers typically are used to restart services or reboot hosts

```yaml
- name: copy index.html
    copy:
        src: /tmp/index.html
        dest: /var/www/html/index.html
    notify:
        - restart_web
handlers:
    - name: restart_web
        service:
            name: httpd
            state: restarted
```

## Using Handlers
- Handlers are executed after running all tasks in a play
- Use `meta: flush_handlers` to run handlers now
- Handler will only run if a task has changed something
- If one of the next tasks in the play fails, the handler will not run, but this may be overwritten using `force_handlers: True`
- One task may trigger more than one handler

## Using ansible.builtin.meta
- Handlers are executed at the end of the play
- To change this behavior, the `ansible.builtin.meta` module can be used
- This module specifis option to influence the Ansible internal execution order
  - `flush_handlers`: will run all notified handlers now
  - `refresh_inventory`: refreshes inventory at the moment it is called

# 7.6 Using Blocks
- Blocks can be used in error condition handling
  - Use `block` to define the main tasks to run
  - Use `rescue` to define tasks that run if tasks defined in `block` fail
  - Use `always` to define tasks that will always run
```yaml
- name: using blocks
  hosts: all
  tasks:
  - name: intended to be successful
    block:
    - name: remove a file
      shell:
        cmd: rm /var/www/html/index.html
    rescue:
    - name: create a file
      shell:
        cmd: touch /tmp/rescuefile
```

## blocks.yml
```yml
---
- name: simple block example
  hosts: all
  tasks:
  - name: setting up http
    block:
    - name: installing http
      yum:
        name: httpd
        state: present
    - name: restart httpd
      service:
        name: httpd
        state: started
    when: ansible_distribution == "RedHat"
```

## block2.yml
```yml
---
- name: using blocks
  hosts: all
  tasks:
  - name: intended to be successful
    block:
    - name: remove a file
      shell:
        cmd: rm /var/www/html/index.html 2>/dev/null
    - name: printing status
      debug:
        msg: block task was operated
    rescue:
    - name: create a file
      shell:
        cmd: touch /tmp/rescuefile
    - name: printing rescue status
      debug:
        msg: rescue task was operated
    always:
    - name: always write a message to logs
      shell:
        cmd: logger hello
    - name: always printing this message
      debug:
        msg: this message is always printed
```

# 7.7 Managing Task Failure
- Ansible looks at the exit status of a task to determine whether it has failed
- When any task fails, Ansible aborts the rest of the play on that host and continues with the next host
- Different solutions can be used to change that behavior
- Use `ignore_errors` in a task or play to ignore failures
- Use `force_handlers` to force a handler that has been triggered to run, even if another task fails
  - Notice that if `ignore_error: yes` and `force_handlers: no` both have been set, the handlers will run after failing tasks 

## Defining Failure States
- As Ansible only looks at the exit status of a failed task, it may think a task was successful where that is not the case
- To be more specific, use `failed_when` to specify what to look for in command output to recognize a failure
  
```yml
- name: run a script
  command: echo hello world
  ignore_errors: yes
  register: command_result
  failed_when: "'world' in command_result.stdout"
```
## Example
### failure.yml
```yml
---
- name: demonstrating failed_when
  hosts: all
  tasks:
  - name: run a script
    command: echo hello world
    ignore_errors: yes
    register: command_result
    failed_when: "'world' in command_result.stdout"
  - name: see if we get here
    debug:
      msg: hello
```

## Using the fail Module
- The `failed_when` keyword can be used in a task to identify when a task has failed
- The `fail` module can be used to print a message that informs why a task has failed
- To use `failed_when` or `fail`, the result of the command must be registered, and the registered variable output must be analyzed
- When using the `fail` module, the failing task must have `ignore_errors` set to yes   

## listing725.yml 
```yml
---
- name: demonstrating the fail module
  hosts: all
  ignore_errors: yes
  tasks:
  - name: run a script
    command: echo hello world
    register: command_result 
  - name: report a failure
    fail:
      msg: the command has failed
    when: "'world' in command_result.stdout"
  - name: see if we get here
    debug:
      msg: second task executed
```

# 7.8 Managing Changed Status
- Ansilble looks at the exit status of commands it runs
- Idempotent modules can make a difference between "changed" and "no changed required"
- Non-idempotent modules like `command` and `shell` cannot do that, and only work with an exit status of 0 or 1, which is next processed by Ansible to determine module success or failure
- Because of this, a non-idempotent module may falsely report changed, when really no change has happened

## Changed Status
- Managing the changed status may be important, as handlers trigger on the changed status
- The result of a command can registered, and the registered variable can be scanned for specific text to determine that a change has occurred
- This allows Ansible to report a changed status, where it normally would not, thus allowing handlers to be triggered
- Using `changed_when` is common in two cases:
  - to allow handlers to run when a change would no normally trigger
  - to disable commands that run successfully to report a changed status

## changed.yml
```yml
---
- name: demonstrate changed status
  hosts: all
  tasks:
  - name: check local time
    command: date
    register: command_result
    changed_when: false
  - name: print local time
    debug:
      var: command_result.stdout
```

# 7.9 Including and Important Files
- If playbooks grow larger, it is common to use modularity by using includes and imports
- Includes and imports can happen for roles, playbooks, as well as tasks
- An _include_ is a dynamic process; Ansible processes the contents of the included files at the moment that this include is reached
- An _import_ is a static process; Ansible preprocessses the imported file contents before the actual play is started
  - Playbook imports must be defined at the beginning of the playbook, using `import_playbook`

## Including Task Files
- A task file is a flat list of tasks
- Use `import_tasks` to statically import a task file in the playbook, it will be included at the location where it is imported
- Use `include_tasks` to dynamically include a task file
- Dynamically including tasks means that some features are not available
  - `ansible-playbook --list-tasks` will not show the tasks
  - `ansible-playbook --start-at-task` doesn't work
  - You cannot trigger a handler in an imported task file from the main task file
- Best practice: store task files in a dedicated directory to make management easier

## includes-and-imports.yaml
```yaml
---
- name: setup a service
  hosts: ansible2
  tasks:
    - name: include the services task file
      include_tasks: tasks/service.yaml
      vars:
        package: httpd
        service: httpd
      when: ansible_facts['os_family'] == "RedHat"
    - name: include the firewall file
      import_tasks: tasks/firewall.yaml
      vars:
        firewall_package: firewalld
        firewall_service: firewalld
        firewall_rules:
        - httpd
        - https
```

# Lesson 7 Lab: Running Tasks Conditionally
- Write a playbook that writes "you have a second disk" if a second disk was found on a node, and "you have no second disk" in the case that no second disk was found.

```yaml
---
- name: Check for a second disk
  hosts: all
  vars:
    disk_name: "sdb"
  tasks:
  - name: find a second disk
    shell:
      cmd: lsblk
    register: lsblk_output
  - name: found
    debug:
      msg: you have a second disk
    when: lsblk_output.stdout.find(disk_name) != -1
  - name: notfound
    debug:
      msg: you have no second disk
    when: lsblk_output.stdout.find(disk_name) == -1
```