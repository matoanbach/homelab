# 1.1 Understanding Ansible
## What is Ansible
- Ansible is software for configuration management
- It uses modules in YAML files to describe the current state of managed systems
- Using Ansible commands, the desired state is compared to the current state of managed systems
- If a difference occurs, Ansible will update the current state with the desired state

## How it works
- Ansible is designed to be simple
- It is developed on top of Python, and uses manifest files written in YAML
- Ansible uses Secure Shell (SSH) to reach out to the managed systems and apply the desired state
- It uses no agents
- You can use Ansible to manage a wide range of different platforms

# 1.2 Understanding Community Ansible Solutions
## Coomunities
- Ansible core is open-source software, provided through `https://github.com/ansible/ansible`
- Ansible core provides essential modules only
- Ansible modules are provided through collections on `https://galaxy.ansible.com`
- Ansible AWX is open-source software, provided through `https://github.com/ansible/awx` that offers the following:
  - A web-based user interface
  - A REST API
  - A task engine 
- **ansible-navigator** is text-based user interface for Ansible.

# 1.3 Understanding the Red Hat Product offering
- The **ansible-core** package is offered as an independent package in RHEL 9, and using it does not require Ansible Automation Platform (AAP)
- It offers limited support
- AAP bundles different open-source components
  - **ansible-core**
  - Ansible Automation Controller, which is based on AWX
  - Supported Ansible Content Collections through Automation Hub, which is available at `https://console.redhat.com`
  - Automation content navigator (**ansible-navigator**) which is introduced as an alternative for **ansible-playbook** and other older commands.
  - Automation Execution Environments, which contain runtime environments with specific modules and other content, used by **ansible-navigator**

## Automation Execution Environments
- An Automation Execution Environment is a container image that contains Ansible Core, Ansible Content Collections and all dependencies needed to run a playbook.
- Execution Environments were introduced to offer a complete solution where it is no longer required to install dependencies separately.
- While using `ansible-navigator`, an execution environment is used to start the playbook
- The `ansible-builder` tool can be used to build custom execution environments
- To use execution environments, a container engine must be available
- To access content, you'll have to log into the appropriate container registries: **podman login registry.redhat.io**

## ansible-navigator and Execution Environments
- When using **ansible-navigator**, a default execution environment is provided
- Additional execution environments can be loaded from navigator
- Within an execution envrionemnt, specific content collections can be provided.