# 13.1 Managing Services and Targets
- `ansible.builtin.service` provides a generic interface used to manage the state of services in different service management systems
- `ansible.builtin.systemd` manages the state of services in systemd, as well as additional systemd specific properties
- There are no modules to manage the default target, use `ansible.builtin.command` instead
- `ansible.builtin.reboot` will reboot a managed host. It can use a `reboot_timeout` and a `test_command` to verify that the host is available again

- Best Practice: Using the command module is not neccessarily bad. Just configure it to be idempotent


## settargetandreboot.yml
```yml
---
- name: change target and reboot
  hosts: all
  gather_facts: no
  vars:
    default_target: multi-user.target
  tasks:
  - name: get current target
    command:
      cmd: systemctl get-default
    changed_when: false
    register: default
  - name: set default target
    command:
      cmd: systemctl set-default {{ default_target }}
    when: default_target not in default['stdout']
    notify: reboot_server

  handlers:
  - name: reboot_server
    reboot:
      test_command: uptime
      reboot_timeout: 300
```

# 13.2 Scheduling Processes
- `ansible.posix.at` is used to run a one-time job at a future time
- `ansible.builtin.cron` is used to run repeating jobs through the Linux cron daemon

## setup-crontab.yml
```yml
---
- name: setup cron job
  hosts: ansible1
  tasks:
  - name: run a cron job
    cron:
      name: "write message to file"
      minute: "*/2"
      hour: 8-18
      user: ansible
      job: echo "entry written at $(date)" >> /tmp/cron-keepalive
      cron_file: keep-alive-messages
      state: present
```

## delete-cronjob.yml
```yml
---
- name: remove a specific cron job
  hosts: ansible1
  tasks:
    - name: remove cron job
      cron:
        name: "write message to file"
        cron_file: keep-alive-messages
        state: absent
        user: ansible
```

# Lesson 13 Lab: Managing the Default Target
- Set the default boot state of the managed servers to multi-user.target
- Reboot your server after doing so
- Configure your playbook such that it will show the message "successfully rebooted" once it is available again

## lab-13.yml
```yml
---
- name: playbook for lab13
  hosts: all
  vars:
    default_target: multi-user.target
  tasks:
  - name: get the default boot state
    command:
      cmd: systemctl get-default
    changed_when: false
    register: default

  - name: set default target
    command:
      cmd: systemctl set-default {{ default_target }}
    when: default_target not in default['stdout']
    notify: 
      - reboot_server
      - print_message

  handlers:
    - name: reboot_server
      reboot:
        test_command: uptime
        reboot_timeout: 300

    - name: print_message
      debug:
        msg: successfully rebooted
```