FROM jenkins/jenkins

USER root

RUN apt-get update && \
    apt-get install -y python3 python3-venv curl && \
    rm -rf /var/lib/apt/lists/*

ENV ANSIBLE_VENV=/ansible_venv

RUN python3 -m venv $ANSIBLE_VENV && \
    $ANSIBLE_VENV/bin/pip install --upgrade pip && \
    $ANSIBLE_VENV/bin/pip install ansible

ENV PATH="${ANSIBLE_VENV}/bin:${PATH}"

USER jenkins
