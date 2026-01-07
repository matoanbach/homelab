# 10.1 Ansible and Logging

## Troubleshooting without Logs
- Relevant Ansible processing information is often written to STDOUT while using the `ansible-playbook` command
- When using `ansible-navigator`, add the option `-m stdout`
- In the output, start by reading the PLAY RECAP section, and if anything is wrong, scroll up to read relevant output
- To increase verbosity of the output of Ansible commands, use one to four `-v` options while running the command: `ansible-playbook -vvv myplay.yml` 

## Understanding Logging
- Ansible commands don't produce any logging, all output is written to STDOUT
- If you want to write output to a log file, use the `log_path:` setting to specify the name of the log directory to be used
  - Do no log to `/var/log`, as it requires `sudo` for write access
- `ansible-navigator` creates playbook artifact files in the directory that contains the playbook. These artifacts have detailed information containing all relevant information about the playbook execution
- The best way to use these artifact files is by accessing the logs from `ansible-navigator` in interactive mode

## Managing ansible-navigator Artifacts
- Artifact files are generated for every playbook run
- This will fill up the project directory if the playbook was run multiple times
- Also, artifact files contain all information that was used, which may contain sensitive information
- To skip artifact creation, configure ansible-navigator.yml to contain the following:

```yml
ansible-navigator:
    playbook-artifact:
        enable: false
```

# 10.2 Using the debug Module

- The `debug` module is useful for analyzing variables
- While using this module, you can use the `verbosity` argument to specify when it should run:
  - Include `verbosity: 2` if you only want to run the `debug` module when the command was started with the `-vv` options

# 10.3 Checking Playbooks for Issues

- To check a playbook for errors, use the `--syntax-check` option with either the `ansible-playbook` or the `ansible-navigator` command
- Also consider avoiding errors by applying some best practices

## Best practices
- Be consistent
- Make sure evey task and play has a name that describes what the play is doing
- Use consistent indentation
- In case of doubt, use the `debug` module to check for variable values
- Keep it simple
- Always use the most specific Ansible solution
- Avoid non-idempotent modules

## ansible-lint
- `ansible-lint` is an optional and not currently supported command
- Also, `ansible-lint` is not registered in the default execution environment
- Use it to check playbooks to verify that best practices have been applied
- Notice that `ansible-lint` may give warnings about issues that aren't really an issue
- For instance: `ansible-lint` will complain if you don't use FQCN while referring to modules; this may be something you deliverately do differently

# 10.4 Using Check Mode

- Use the `--check` option while running a playbook to perform check mode; this will show what would happen when running the playbook without actually changing anything
  - Modules in the playbook must support check mode
  - Check mode doesn't always work well in conditionals
- Set `check_mode: yes` within a task to always run that specific task in check mode
  - This is useful for checking individual tasks
  - When setting `check_mode: no` for a task, this task will never run in check mode and give you normal behavior (as if running without `--check`)

## Using Check Mode on Templates
- Add `--diff` to an Ansible playbook run to see differences that would be made by template files on a managed hosts
  - `ansible-playbook --check --diff myplaybook.yml`

# 10.5 Using Modules for Troubleshooting and Testing
## Modules for Checking
- `uri`: checks content that is returned from a specific URL
- `script`: runs a script from the control node on the managed hosts
- `stat`: checks the status of files; use it to register a variable and then tests to determine if a file exists
- `assert`: this module will fail with an error if a specific condition is not met 

## Using stat
- The `stat` module can be used to check on file status
- It returns a dictionary that contains a stat field what can have multiple values
  - `atime`: last access time of the file
  - `isdir`: true if a file is a dir
  - `exists`: true if a file exists
  - `size`: size in bytes
  - ...

# 10.6 Troubleshooting Connectivity Issues
- Connection issues might include the following
  - Issues setting up the physical connection
  - Issues running tasks as the target user

## Analyzing Authentication Issues
- Confirm the `remote_user` setting and existence of remote user on the managed host
- Confirm host key setup
- Verify `become` and `become_user`
- Check that Linux `sudo` is configured correctly 

## Connecting to Managed Hosts
- When a host is available at different IP addresses / names, you can use `ansible_host` in inventory to specify how to connect
- This ensures that the connection is made in a persistent way, using the right interface
- `web.example.com ansible_host=192.168.4.100`

## Using ad-hoc commands to Test Connectivity
- The `ping` module was developed to test connectivity
- Use the `--become` option to run with administrative privileges
  - `ansible ansible1 -m ping`
  - `ansible ansible1 -m ping --become`
- Use the `command` module to test different items
  - `ansible ansible1 -m command -a 'df'`
  - `ansible ansible1 -m command -a 'free -m'`

# Lesson 10 Lab: Troubleshooting Playbooks
- Write a playbook that checks if network interface ens34 exists on ansible2
```yaml
---
- name: playbook for lab10
  hosts: ansible2
  tasks:
  - name: check
    assert:
      that:
        - ansible_facts['ens160'] is defined
      fail_msg: no ens160
      success_msg: there is ens160
```