# Lesson 21: Managing the Boot Procedure
- 21.1 Exploring the Boot Procedure
- 21.2 Modifying Grub2 Runtime Parameters
- 21.3 Chaning Grub2 Persistent Parameters
- 21.4 Managing Systemd Targets
- 21.5 Setting the Default Sytemd
- 21.6 Booting into a Specific Target

## 21.2 Modifying Grub2 Runtime Parameters
### Modifying Grub2 Runtime Parameters
- When the GRUB menu appears at boot, press `e` to edit the highlighted entry
- Find the line that starts with linux and add your extra option at the end
    - For example:
        - `systemd.unit=emergency.target` - boots into a minimal emergency shell
        - `systemd.unit=rescue.target` - boots into single-user rescue mode
- `ctrl-x` or `F10` to boot with these temporary settings
- If you press c instead of e, you enter GRUB's command prompt - type help there to see available commands

## 21.3 Chaning Grub2 Persistent Parameters
### Modifying Grub2 Persistent Parameters
- To edit persistent Grub2 parameters, edit the configuration file in `/etc/default/grub`
- After writing changes, compile changes to grub.cfg
    - `grub2-mkconfig -o /boot/grub/grub.cfg`
    - `grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg`

## 21.4 Managing Systemd Targets
### Understanding Systemd Targets
- A systemd target is just a named group of unit files that define a particular system state.
- Some targets are isolatable, meaning the system boots directly into that state and stops starting any other targets. Examples:
    - `emergency.target` (minimal boot, only an emergency shell)
    - `rescue.target` (single-user rescue mode)
    - `multi-user.target` (normal text-mode multiuse)
    - `graphical.target` (normal multiuser with GUI)
- When you enable or start a unit systemd adds it under one of these target so it loads in that runlevel-like state

## 21.5 Setting the Default Systemd Target
### Setting the Default Systemd Target
- `systemctl get-default` to see the current default target
- `systemctl set-default` to set a new default target

## 21.6 Booting into a Specific Target
- `systemd.unit=xxx.target` to boot into a specific target
- `systemctl isolate xxx.target` to change between targets on a running system

## Lesson 21 Lab - Managing the Boot Procedure
- Configure your system to boot in a multi-user target by default
- Persistently remove the options that hide startup messages while booting