## 13.1 Performing container management
### Task
- Log in to the default Red Hat container registries.
- Start the bitnami nginx container image in detached mode.
- Configure access such that this container is accessible from host port 81.
- Solution
```bash
podman login [red hat registry] # find the right red hat registries to login
podman search bitnami | grep nginx
podman run -d -p 81:8080 docker.io/bitnami/nginx
```

### Key Elements
- Rootless containers are more secure, but in some cases cannot be used.
- Each user account that needs access to container registries, needs to authenticate on these registries.
- The `podman run` command offers many options, use `man podman-run` for a complete overview.

## 13.2 Managing storage
### Task
- As user `linda`, create a container with the name `mydb` that starts the mariadb-105 image which is based on RHEL 9. Make sure it meets the following requirements:
    - The container `/var/lib/mysql` directory is mounted on the directory `mydb` in user `linda's` home directory.
    - The container is started in the background.
    - The container MYSQL_ROOT_PASSWORD variable is set to `password`.
    - SELinux is operational and allowing access.
    - The container can be accessed at host port 3306.

- Solution
```bash
loginctl enable-linger linda
su - linda
mkdir mydb
podman search mariadb-105
podman pull [mariadb-105 image from your choice of registry]
podman run -d -p 3306:3306 -name mydb -e MYSQL_ROOT_PASSWORD -v mydb:/var/lib/mysql:Z registry/mariadb-105
podman exec mydb cat /etc/passwd
podman unshare chown 27:27 mydb
podman unshare cat /proc/self/uuid-map
```

### Key Elements
- The container user must have access permissions to the mounted directory on the host operating system.
- Normally, the user ID within the container is represented by the numeric user ID +99999 on the host operating system.
- The `podman unshare` command can be used to apply changes in the container namespace.

## 13.3 Using Containerfile
### Task
- In the course Git repository, you'll find the file lesson13/Containerfile. Build a container image with the name `helloworld:1.0` based on this containerfile.
- Start this image once.

## 13.4 Systemd integration
### Task
- Create a systemd unit file that will start the `mydb` container created ealier as user `linda`.
- The container should automatically be started when the system boots and not depend on the user login.
- Solution:
```bash
loginctl enable-linger linda
loginctl get-user linda
ssh linda@localhost
mkdir -p ~/.config/systemd/user
cd ~/.config/systemd/user 
# make sure there is one container existing before creating a service config file.
podman generate systemd --name mydb --files --new
systemctl --user daemon-reload
systemctl --user enable --now container-mydb.service
exit

# run following commands under root
loginctl user-status linda # to make sure the service is still running after linda logging out
ps fax | grep linda # also to verify the service is running
```

### Key Elements
- The `podman generate` command is used to generate Systemd unit files from running containers.
- Use `man podman-generate-systemd` for usage information.
- While using this command, make sure you are in the directory `~/.config/systemd/user`.