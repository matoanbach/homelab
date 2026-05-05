## 6.1 Managing systemd
### Task
- Use your package manager to install the nginx service as well as the httpd service.
- Solution:

    ```bash
    dnf install httpd nginx -y
    systemctl status httpd
    systemctl status nginx
    ```
- Configure systemd such that nginx can never be started. The httpd service should be started when your server boots. Also, ensure that if the httpd process stops for unforseen reasons, it will automatically restart after 21 seconds.
- Solution:

```bash
systemctl mask nginx
systemctl start nginx # expect an error

systemctl edit httpd

# write the below to the editor:
[Service]
Restart=on-failure
RestartSec=21s

systemctl daemon-reload
```

### Key Elements
- Unit files in systemd can be configured with many directives.
- Use `systemctl show` to get a list of all directives.
- `man systemd.directives` provides a list of all directives, and a reference to the man page that contains further explanation about that directive.
- The `systemctl` command offers `Tab` completion and is helpful if you don't exactly remember which command to use.
- With any `systemctl` command, use the `--help` option to get additional usage information.


## 6.2 Tuning
### Task
- Configure your system for optimal power usage efficiency.
- Solution:
```bash
dnf install tuned -y
dnf list
dnf profile powersave
dnf active # to verify 
```

- Key Elements
- The Linux kernel can be tweaked by modifying parameters in the `/proc/sys` directory.
- To make persistent modifications, changed parameters should be included in the `/etc/sysctl.conf` file, or the related `/etc/sysctl.conf.d` directory.
- To make system configuration easier, the `tuned` service is provided.
- This service comes with pre-defined performance profiles that match specific workloads.
- The `tuned-adm` command can be used to set the desired profile in an easy way.