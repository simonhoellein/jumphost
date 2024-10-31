ARG CODE_VERSION=latest
FROM alpine:${CODE_VERSION} AS os-base

# Install needed software
RUN apk update && \
    apk add \
        openssh \
        openssh-server \
        screen \
        vim \
        logrotate \
        netcat-openbsd \
        git \
        zsh \
        curl

# Install ohmyzsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Clone config files
RUN git clone https://github.com/simonhoellein/dotfiles.git /root/dotfiles && \
    cp -r dotfiles/* /root/.

# Add SSH-Keys from github
RUN curl https://github.com/simonhoellein.keys >> ./ssh/authorized_keys

# Add sshd config
ADD config/openssh-server/sshd_config /etc/ssh/sshd_config

# Expose SSH Port for udp and tcp
EXPOSE 22/tcp
EXPOSE 22/udp

ENTRYPOINT [ "/bin/sh" ]

# Labels
LABEL org.opencontainers.image.authors="simon@shoellein.de"
LABEL description="ssh jumphost server with enabled shell and some utilitys"