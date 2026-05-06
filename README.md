# Homelab

## Overview

This repository documents my personal homelab.

I use this homelab to practice infrastructure, systems, platform, and automation skills in a hands-on environment. Instead of only learning concepts from courses or documentation, I use this lab to build real setups, troubleshoot failures, rebuild environments, and document what I learn along the way.

At the center of the lab is a Proxmox host that I use to run virtual machines for Linux administration, networking exercises, Kubernetes, OpenShift, Terraform, Ansible, and Jenkins experiments.

This repo serves two purposes:

- a working knowledge base for what I am learning
- a place to keep the configs, notes, and setup files that support the lab

## Goals

The main goal of this homelab is skill development through repetition and practice.

I use it to improve in areas such as:

- Proxmox virtualization
- Linux system administration
- Red Hat and RHCSA-style tasks
- networking fundamentals and troubleshooting
- Infrastructure as Code with Terraform
- configuration management with Ansible
- Kubernetes cluster setup and operations
- OpenShift installation and administration
- Jenkins and CI/CD workflows
- documenting builds and operational lessons learned

The focus is not just getting something to work once. The focus is learning how to build it again, automate it, and understand why it works.

## Lab Hardware

Current host hardware:

- Platform: Proxmox VE
- Host: HP 840
- Memory: 64 GB RAM
- Storage: 500 GB
- CPU: dual Intel Xeon E5-2660 v3
- Per CPU: 10 cores @ 2.60 GHz
- Total physical cores: 20

This gives me enough room to run multiple VMs for cluster, automation, and Linux administration practice inside one self-hosted environment.

## What I Practice Here

### Virtualization

Proxmox is the foundation of the homelab. I use it to practice:

- creating and sizing VMs
- attaching install media and boot images
- bridge networking
- storage allocation
- rebuilding environments from scratch
- planning repeatable VM layouts for clusters

### OpenShift on Proxmox

One of the main hands-on projects in this repo is running OpenShift on Proxmox.

That work includes:

- planning a compact OpenShift cluster
- configuring the agent-based installer
- mapping static IPs, DNS, and node roles
- using Terraform to automate provisioning on Proxmox
- managing cluster-related setup files and notes

This work lives under `notes/openshift/`.

### Kubernetes

I also use this homelab to practice Kubernetes outside of OpenShift.

Topics in the repo include:

- cluster formation
- Kubespray-based setup
- Helm
- Kubernetes learning notes
- comparing different ways to build and operate clusters

This work lives under `notes/k8s/`.

### Automation

Automation is a major reason this homelab exists.

I use it to practice:

- Terraform for infrastructure provisioning
- Ansible for configuration management
- repeatable setup workflows
- turning manual setup steps into documented and automated processes

Relevant sections include `notes/terraform/`, `notes/ansible/`, and parts of `notes/openshift/`.

### Linux and Red Hat Administration

The homelab is also where I practice Linux administration, especially Red Hat-oriented tasks.

That includes:

- users, groups, and permissions
- services and systemd
- storage and filesystems
- networking
- shell scripting
- troubleshooting
- RHCSA-style exercises

This work lives under `notes/red-hat-enterprise-linux/`.

### Networking

I use the lab to reinforce networking concepts that support systems and platform work.

That includes:

- IP addressing and subnetting
- switching and VLAN concepts
- routing fundamentals
- DNS and basic name resolution planning
- SSH and remote access
- troubleshooting connectivity issues
- CCNA-aligned study and lab mapping

This work lives under `notes/networking/`.

### Jenkins and CI/CD

I also use the lab for Jenkins and automation workflow practice.

That includes:

- Jenkins setup experiments
- Docker-based Jenkins files
- pipeline-related practice material
- automation-oriented CI/CD learning

This work lives under `notes/jenkins/`.

## Repository Structure

```text
notes/
  ansible/                    Ansible learning and automation notes
  images/                     Supporting images and assets
  jenkins/                    Jenkins lab files and experiments
  k8s/                        Kubernetes learning, cluster setup, and Helm
  networking/                 Networking notes, labs, and study mapping
  openshift/                  OpenShift on Proxmox configs and documentation
  red-hat-enterprise-linux/   RHEL and RHCSA-related notes
  terraform/                  Terraform-related notes and experiments
```

## How to Read This Repo

This is a working lab repository, not a polished product repository.

That means it contains a mix of:

- step-by-step setup guides
- architecture notes
- study notes
- lab experiments
- infrastructure files
- incomplete or evolving drafts

Some sections are structured tutorials. Some are rough working notes captured while learning or troubleshooting.

## Current Focus

The most infrastructure-heavy section in this repository is the OpenShift on Proxmox work under `notes/openshift/`.

That area includes:

- cluster design
- network layout
- installer inputs
- Terraform configuration
- provisioning workflow notes

## Principles

This homelab is mainly for learning, repetition, and operational understanding.

- It is a practice environment, not a production environment.
- The goal is to build, break, fix, and document.
- Repeatability matters more than one-time success.
- Documentation is part of the practice.
- Sensitive values should be kept out of version-controlled files when possible.

## Summary

This homelab is my personal practice environment for virtualization, Linux, networking, Kubernetes, OpenShift, automation, and CI/CD, all centered around a Proxmox host.

It is where I learn by building.
