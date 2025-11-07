# Using the Command-Line Interface
## Cisco 2960-XR Catalyst Switch Series

## CLI Access Points

## Console Connection to a Switch

## A Part of a 2960-XR Switch with Console Ports Shown

## Terminal Settings for Console Access

## User and Enable (Privileged) Modes

## Example of Privileged Mode Commnads Being Rejeted in User Mode

## Nondefault Basic Configuration

## Cisco IOS Softare Command Help

## Key Sequences for Command Edit and Recall

## Nondefault Basic Configuration

## CLI Configuration Mode Versus Exec Modes

## Navigating Between Different Configuration Modes

## Command Switch Configuration Modes

## Navigation In and Out of Switch Configuration Modes

## Cisco Switch Memory Types
<img src="https://github.com/matoanbach/networking/blob/main/pics/w3.6.png"/>

## Two Main Cisco IOS Configuration Files
| Configuration  | Purpose                                                                                                                          | Where it is stored |
|----------------|----------------------------------------------------------------------------------------------------------------------------------|--------------------|
| startup-config | Stores the initial configuration used anytime the switch reloads Cisco IOS.                                                      | NVRAM              |
| running-config | Store the currently used configuration commands. The file changes dynamically when someone enters commands in configuration mode | RAM                |

## How Configuration Mode Commands Change the Running-Config File, Not the Startup-Config File
```
write memory
copy running-config start-config
```

- Get rid of all existing configuration and start over with a clean configuration:
```bash
write erase
erase startup-config
erase nvram
```

# Analyzing Ethernet LAN Switching