## 10.1 Restricting network access
### Task
- Configure your system such that the httpd service is accessible for external users on port 80 and 443, using its default configuration.
- Solution:

```bash
dnf install -y httpd
firewall-cmd --get-services # to get all available services (those are not set up yet)
firewall-cmd --list-all # to see if http, https, port 40 and 443 are already there
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --reload
```

### Key Elements
- To run a service, it needs to be installed. If you're not sure about the name of the service, use `dnf provides */servicename`.
- After installing a service, it should be started and enabled using systemd.
- Firewalling is handled by `firewalld`, which runs as a systemd service.
- To set up firewalling easily, use the `firewalld` services that are provided and configure access with `firewall-cmd`

## 10.2 Restricting network access
### Task
- Set your hostname to `examlabs.local`.
- Ensure that this hostname is resolved to the IP address your host is using.
- Solution:

```bash
hostnamectl hostname examlabs.local
hostnamectl # to verify the hostname is set
ip a # to copy the address of your machine
vim /etc/hosts
# append the line below to /etc/hosts:
[ip address]       examlabs.local
ping -c 5 examlabs.local # to verify it's working properly
```