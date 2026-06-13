# Jenkins

## Purpose

Jenkins is the CI engine for this platform. It builds and tests application code, publishes images, and updates Git so Argo CD can deploy the result.

## Why It Is Needed

- keeps CI separate from the Kubernetes cluster
- avoids GitHub-hosted runner limits and cost concerns
- works well on a dedicated Proxmox VM

## Recommended Pattern For This Project

Use a dedicated Jenkins VM on Proxmox.

```text
git push
-> GitHub webhook
-> Jenkins pipeline
-> image build and GHCR push
-> Git manifest or Helm values update
-> Argo CD sync
-> Kubernetes deployment
```

Keep CI in Jenkins and CD in Argo CD. Do not give Jenkins direct cluster-admin access unless there is a clear reason.

## Recommended VM Size

Starter size:

- 2 vCPU
- 4 GiB RAM
- 50 GiB disk on `local-lvm`

Increase later if builds become heavy:

- 4 vCPU
- 8 GiB RAM
- 80 GiB disk

Disk matters because Docker image layers and build caches grow quickly.

## Prerequisites

- Ubuntu cloud-init template already available in Proxmox
- SSH public key available for cloud-init
- free LAN IP for the Jenkins VM
- Docker and GHCR usage planned for pipelines

## VM Creation In Proxmox

On Proxmox, the shell tool for QEMU VMs is `qm`.

First identify the Ubuntu template VMID:

```bash
qm list
```

Create the Jenkins VM from the template:

```bash
TEMPLATE_VMID=<template-vmid>
VMID=<new-vmid>
VM_NAME=jenkins
JENKINS_IP=<jenkins-ip>
GATEWAY=10.0.0.1
DNS_SERVER=10.0.0.1
SEARCH_DOMAIN=local
SSHKEY_FILE=/root/.ssh/id_rsa.pub

qm clone "$TEMPLATE_VMID" "$VMID" --name "$VM_NAME" --full 1 --storage local-lvm
qm set "$VMID" --cores 2 --sockets 1 --cpu host --memory 4096
qm set "$VMID" --net0 virtio,bridge=vmbr0
qm set "$VMID" --agent 1
qm set "$VMID" --ciuser ubuntu
qm set "$VMID" --sshkeys "$SSHKEY_FILE"
qm set "$VMID" --ipconfig0 ip=${JENKINS_IP}/24,gw=${GATEWAY}
qm set "$VMID" --nameserver "$DNS_SERVER" --searchdomain "$SEARCH_DOMAIN"
qm resize "$VMID" scsi0 50G
qm start "$VMID"
```

Replace:

- `<template-vmid>` with the Ubuntu template VMID
- `<new-vmid>` with an unused VMID
- `<jenkins-ip>` with the Jenkins VM static IP
- `SSHKEY_FILE` with the public key path you want injected by cloud-init

After the VM boots, verify the config from Proxmox:

```bash
qm config <new-vmid>
```

Then SSH into the VM:

```bash
ssh ubuntu@<jenkins-ip>
```

## Base OS Setup

Inside the Jenkins VM:

```bash
sudo apt update
sudo apt upgrade -y
sudo apt install -y ca-certificates curl wget gnupg qemu-guest-agent
sudo systemctl enable --now qemu-guest-agent
```

## Install Docker

```bash
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
sudo docker version
```

## Install Jenkins

Install Java before Jenkins.

```bash
sudo apt install -y fontconfig openjdk-21-jre
java -version
```

Add the Jenkins repository with the current signing key and install Jenkins:

```bash
sudo install -d -m 0755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install -y jenkins
sudo systemctl enable --now jenkins
```

If you are retrying after a failed attempt, it is safe to overwrite `/etc/apt/keyrings/jenkins-keyring.asc` and `/etc/apt/sources.list.d/jenkins.list` with the commands above.

## Allow Jenkins To Use Docker

```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

## First Login

Check Jenkins status:

```bash
sudo systemctl status jenkins --no-pager
```

Get the initial admin password:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Open the UI on:

```text
http://<jenkins-ip>:8080
```

Install the suggested plugins first. Useful early plugins for this project:

- Git
- Pipeline
- GitHub Integration
- Docker Pipeline

## Access Strategy

Start with LAN-only access while you finish setup.

- use `http://<jenkins-ip>:8080` first
- configure authentication before exposing Jenkins outside the LAN
- if you expose it later through Cloudflare Tunnel, put it behind Cloudflare Access or another access control layer

## First Pipeline Direction

For this project, Jenkins should:

- clone the application repo
- run tests
- build an image
- push the image to GHCR
- update Git-tracked deployment manifests or Helm values

Argo CD should then detect the Git change and deploy it.

## Verification

```bash
ssh ubuntu@<jenkins-ip>
sudo systemctl status jenkins --no-pager
sudo journalctl -u jenkins.service -b -n 50 --no-pager
docker version
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Expected result:

- the VM is reachable over SSH
- Jenkins service is `active (running)`
- Docker works on the VM
- Jenkins UI loads on port `8080`
- the initial admin password can be retrieved

## Troubleshooting

- If `apt update` shows a Jenkins GPG key error, refresh the key with `jenkins.io-2026.key`
- If Jenkins does not start, inspect `sudo journalctl -u jenkins.service -b -n 100 --no-pager`
- If the UI does not load, check that port `8080` is reachable on the VM
- If Jenkins cannot build Docker images, verify the `jenkins` user is in the `docker` group and restart the service
- If disk fills up, prune unused images and increase the VM disk size

## Notes For This Cluster

- Keep Jenkins outside the cluster for the first implementation
- Keep CI in Jenkins and CD in Argo CD
- A separate deploy repo is cleaner long term, but using the same repo first is acceptable for speed

## Reference

- https://www.jenkins.io/doc/book/installing/linux/
- https://www.jenkins.io/doc/book/pipeline/docker/
- https://ghcr.io
