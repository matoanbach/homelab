# Lesson 31: Running Containers
- 31.1 Understanding Containers
- 31.2 Managing Images
- 31.3 Running Containers
- 31.4 Mapping Ports and Configuring Variables
- 31.5 Providing Persistent Storage
- 31.6 Starting Containers as Systemd Services

## 31.1 Understanding Containers
### Understanding Containers
- A container bundlers an application together with everything it needs (libraries, runtimes, configs) so it runs the same way everywhere - like an app on your phone
- They solve "it works on my machine" by isolating dependencies inside the container image
- You launch containers from images, which are read-only templates stored in registries (e.g. Docker Hub or a private registy)
- At runtime, a container engine (Podman, Docker, CRI-O) creates a lightweight, isolated environment for each container, sharing the host kernel by keeping files and processes neatly separated.

### Understanding Rootless Containers
- Normally, containers run with root privleges on the host (they map container "root" to host root)
- Rootless containers let you run containers as an ordinary user - no need for sudo or elevating to root.
- Under the hood they use user namespaces to map container UIDs to unpriviledged host UIDs (either picked dynamically or preconfigured)

- Key trade-offs:
    - Rootless containers can't bypass host file permissions - you can only write where your host user has access
    - They also can't bind ports below 1024 (privileged ports), since those require root on the host

- Everything else (images, volumes, networking) works the same, but now any user can safely launch containers without needing root on the system

### Containers and Microservices
- Big applications are broken into small, single-purpose services ("microservices")
- Each microservices lives in its own container - one container = one app
- This division makes it easier to update, scale, and manage each piece independently
- To run lots of containers together in production, you use an orchestration platform like K8S or OpenShift

### Understanding Red Hat Container Tools
- `podman` manages containers and container images
- `buildah` is an advanced tool to create container image
- `skopeo` is an advanced tool to manage, copy, delete and sign images

## 31.2 Managing Images
### Using images and Registries
- A container image bundles an app plus everything it needs (libraries, config, runtime)
- Images follow OCI (Open Container Initiative) spec, ensuring any compliant engine (Podman, Docker, etc.) can run them
- Registries are servers that store and distribute images - public (Docker Hub, Quay.io) or private
- To run an app, you pull its image from a registry and then start a container from that image on your host.

### Using Registries
- **Public registries** (e.g. Docker Hub) host community-provided images you can pull freely
- **Private registries** let you run your own internal image store for custome apps
- **Red Hat Official Images** live at registry.redhat.io (requires your RH subscription)
- **Third-part certified Images** are at registry.connect.redhat.com
- **Quay.io** offers Red Hat-optimized community images
- Browse everything in the Red Hat container catalog: `https://catalog.redhat.com`
- Whenever you run a container, you simply pull its image from the appropriate registry

### Accessing Red Hat Registries
- Red Hat registries can be accessed with a Red Hat account
- Developer accounts (https://developers.redhat.com) do qualify
- `podman login registy.redhat.io` to login to a registry
- `podman login registry.redhat.io --get-login` to get your current login credentials

### Configuring Registry Access
1. Global config file: `/etc/containers/registries.conf`
2. Default pull order:
```bash
unqualified-search-registries = ["registry.fedoraporject.org"]
```
- List which registries to try, in order, when you run podman pull <image> without an explicit registry

3. Allowing insecure (HTTP or self-signed) registries:
```bash


```
4. Per-use overrides:
- Copy the same structure into ~/.config/registries.conf if you need custom settings just for your account

### Using Containerfile
- A Containerfile (previously known as Dockerfile) is a text file with instructions to build a container image
- Containerfiles have instructions to build a custom container based on a base image such as the UBI image
- UBI is the Universal Base Image, an image that Red Hat uses for all of its products

### Demo: Building an image from a Containerfile
```bash
dnf install container-tools
git clone https://github.com/sandervanvugt/rhcsa
podman info
cd rhcsa
podman images
podman login registry.access.redhat.com
podman build -t myapp .
podman images
```

## 31.3 Running Containers
### Running Containers
- `podman run <image>`
    - Looks in your local storage or configured registries for <image>
    - If missing, pulls it, then starts a new container from that image
- `podman ps` to show activate containers
- `podman ps -a` to show all containers
- `podman inspect` to inspect details of an image or container

### Common **podman** commands
- `podman search` to search the registries for images
- `podman run` to run a container
- `podman stop` to stop a currently running container
- `podman ps` to show information about containers
- `podman build` to build an image from a Containerfile
- `podman images` to list images
- `podman inspect` to show container or image details
- `podman pull` to pull an image from the registry
- `podman exec` to execute a command in a running container
- `podman rm` to remove a container

### Demo: Running Containers
```bash
podman search ubi
podman run --name sleepy docker.io/redhat/ubi9 sleep 3600
# from another terminal: podman ps
podman stop sleepy
podman images
podman run -d --name sleepy docker.io/redhat/ubi9 sleep 3600
podman rm sleepy
podman ps -a
```

### Troubleshooting Containers
- Containers often fail because their main command errors out or immediately exits
- `podman inspect <container> --format '{{.Config.Cmd}}'` to check when command
- `podman run -it <image> /bin/bash` to run interactively
- `podman logs <container>` to view output
- Remember: If a container immediately exits, it probably did exactly what its default command told it to - inspect and then override that entrypoint/command to debug

## 31.4 Mapping Ports and Configuring Variables
### Demo:  Using Emvironment Variables
```bash
podman run --name mydb quay.io/centos7/mariadb-103-centos7
podman ps -a
pomdan logs mydb
skopeo inspect docker://quay.io/centos7/mariadb-103-centos7
podman rm mydb
podman run --name mydb -e MYSQL_ROOT_PASSWORD=password quay.io/centos7/mariadb-103-centos7
```

### Demo: Mapping Ports
```bash
# run as non-root user
podman login registry.access.redhat.com
podman run -d -p 80:80 registry.access.redhat.com/ubi9/nginx-120
podman run -d -p 8080:80 registry.access.redhat.com/ubi9/nginx-120
podman port -a
sudo firewall-cmd --add-port=8080/tcp --permanent
sudo firewall-cmd --reload
```
## 31.5 Providing Persistent Storage
### Managing Storage
- Containers' built-in storage is ephemeral - it vanishes when the container is removed
- To keep data around, bind-mount a host directory into your container, e.g:
```bash
podman run -d \
    -v /path/on/host:/path/in/container \
    myapp
```

- Permissions matter:
    - As **root**, Podman maps container UIDs/GIDs straight to host UIDs/GIDs - so files you write will be owned by root on your host
    - As a **non-root** (rootless mode), make sure your UID owns /path/on/host so the container process can read/write it
- That way, anything the container writes under /path/in/container persists in /path/on/host even after the container stops

### Rootless Containers and Namespaces
- Run as an ordinary user
    - No need for host root - your containers run under your own UID
- User namespaces isolate IDs
    - Inside the container, UID 0 ("root") maps to an unprivileged host UID - so container "root" can't actually break out on the host
- UID remapping keeps things safe
    - The kernel translates container UIDs/GIDs to a sub-range of your real user's IDs
- Inspect your mapping
    - `podman unshare cat /proc/self/uid_map`
- Enter the namespace to debug
    - `podman unshare -- bash`

### Non-Root Container UID Mapping
- Rootless containers run inside a user namespace where container "root" maps to an unprivileged host UID. To bind-mount a host directory, that directory must be owned by the mapped container UID
- Find the container's UID
    - `podman inspect <imagename> --format '{{.Config.User}}'`
    - `podman exec -it <container> grep '^appuser:' /etc/passwd` 
    - `podman unshare cat /proc/self/uid_map` to see your UID mappings
- Finx ownership on the host
    - inside your user namespace, change the host directory's owner to that mapped UID

        ```bash
        podman unshare chown 100000:100000 /path/on/host
        ```
- Verify:

    ```bash
    ls -l /path/on/host
    ```

### Demo: Bind Mounting in Rootless Containers
```bash
Run as non-root user
podman search mariadb | grep quay
podman run -d --name mydb -e MYSQL_ROOT_PASSWORD=password quay.io/centos7/mariadb-103-centos7
podman exec mydb grep mysql /etc/password
mkdir mydb # must be in current user homedir
podman unshare chown 27:27 mydb
podman unshare cat /proc/self/uid_map
ls -ld mydb
```
- At this point ownership is set correctly, you'll next have to take care of SELinux before using `podman run -v ...` to bind mount the directory

### Configuring SELinux for Shared Directories
- To bind mount a host directory in the container, the **container_file_t** SELinux context type must be used
- If ownership on the host directory has been configured all right, use **:Z** option to automatically set this context:
    - `podman run ... -v /home/student/my`

### Demo: Bind Mounting in Rootless Containers
- As file ownership has been taken care of in the preceding steps, you're now ready to bind mount, taking care of SELinux as well
```bash
podman stop mydb
podman rm mydb
podman run -d --name mydb -e MYSQL_ROOT_PASSWORD=password -v /home/student/mydb:/var/lib/mysql:Z quay.io/centos7/mariadb-103-centos7
ls -Z /home/user
```

## 31.6 Starting Containers as Systemd Services
### Running Systemd Services as a User
- Systemd user services start when a user session is opened, and close when the user session is stopped
- Use `loginctl enable-linger` to change that behavior and start user services for a specific user (requires root privileges)
    - `loginctl enable-linger linda`
    - `loginctl show-user linda`
    - `loginctl disable-linger linda`

### Managing Containers Using Systemd Services
- Create a regular user account to manage all containers
- Use `podman` to generate a user systemd file for an existing container
- Before, `mkdir ~/.config/systemd/user; cd ~/.config/systemd/user`
- Notice the file will be generated in the current directory
    - `podman generate systemd --name myweb --files --new`
- To generate a service file for a root container, do it from /etc/systemd/system as the current directory

### Understanding `podman generate --new`
- The `podman generate --new` option will create a new container when the systemd unit is started, and delete that container when the unit is stopped
- Wihtout the `--new` option, the container is now newly created or deleted when it is stopped

### Creating User Unit Files
- Use `podman generate` to create user-specific unit files in ~/.config/systemd/user
- Edit the file that is generated and change the `WantedBy` line such that it reads `WantedBy=default.target`
- Manage them using `systemctl --user`
    - `systemctl --user daemon-reload`
    - `systemctl --user enable myapp.service` (requires linger)
    - `systemctl --user start myapp.service`
- `systemctl --user` commands only work when logging in on console or SSH and do not work in sudo and su sessions

### Demo: Autostarting User Containers
```bash
sudo useradd linda; sudo passwd linda
sudo loginctl enable-linger linda
ssh linda@localhost
mkdir -p ~/.config/systemd/user; cd ~/.config/systemd/user
podman run -d --name myngix -p 8081:80 nginx
podman ps
podman generate systemd --name mynginx --files --new
vim container-mynginx.service
    WantedBy=default.target
systemctl --user daemon-reload
systemctl --user enable container-mynginx.service
systemctl --user status container-mynginx.service
```

### Surviving all Challenges
- Log in as the user that should start the container, do NOT use `su -`
    - set a password to do so
- As that user, `mkdir -p ~/.config/systemd/user; cd ~/.config/systemd/user`
- From that directory: `podman generate --new`
- After generating, make sure that the container-name.service file has `WantedBy=default.target` (not just multi-user.target)

## 31.7 Building Images from Containerfiles
## Lesson 31 Lab: Running Containers
- Ensure that you have full access to the Red Hat Container repositories
- Run a Mariadb container in Podman, which meets the following conditions
    - The container is started as a rootless container by user student
    - The container must be accessible at host port 3206
    - The database root password should be set to password
    - The container uses the name mydb
    - A bind-mounted directory is accessible:: the directory /home/student/mariadb on the host must be mapped to /var/lib/mysql in the container
- The container must be configured such that it automatically starts as auser systemd unit upon start of the computer