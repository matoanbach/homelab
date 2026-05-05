FROM quay.io/centos/centos:stream9

RUN yum -y install openssh-server

RUN useradd remote_user && \
    echo "remote_user:1234" | chpasswd && \
    mkdir /home/remote_user/.ssh && \
    chmod 700 /home/remote_user/.ssh

COPY remote-key.pub /home/remote_user/.ssh/authorized_keys

RUN chown remote_user:remote_user -R /home/remote_user && \
    chmod 400 /home/remote_user/.ssh/authorized_keys

RUN ssh-keygen -A && rm -rf /run/nologin

RUN yum -y install python3-pip && \
    pip3 install --upgrade pip && \
    pip3 install awscli

RUN yum -y install mysql

CMD /usr/sbin/sshd -D
