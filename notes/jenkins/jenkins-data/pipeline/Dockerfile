FROM jenkins/jenkins

USER root

RUN apt-get update && \
    apt-get install -y \
      python3-pip \
      python3-venv \
      ca-certificates \
      curl \
      sudo && \
    rm -rf /var/lib/apt/lists/*

ENV ANSIBLE_VENV=/ansible_venv

RUN python3 -m venv $ANSIBLE_VENV && \
    chown -R jenkins:jenkins $ANSIBLE_VENV

USER jenkins

RUN $ANSIBLE_VENV/bin/pip install --upgrade pip ansible

ENV PATH="${ANSIBLE_VENV}/bin:${PATH}"

USER root

RUN usermod -aG sudo jenkins && \
    echo 'jenkins ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/jenkins && \
    chmod 440 /etc/sudoers.d/jenkins

# Add Docker official GPG key
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repo
RUN echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  > /etc/apt/sources.list.d/docker.list

# Install Docker CLI + compose plugin
RUN apt-get update && \
    apt-get install -y docker-ce-cli docker-compose-plugin && \
    rm -rf /var/lib/apt/lists/*

# Let jenkins access docker.sock group if GID 1 is used
RUN if ! getent group 1 >/dev/null; then groupadd -g 1 dockerhost; fi && \
    usermod -aG 1 jenkins

USER jenkins
