FROM ubuntu:24.04 AS os-base

# Install needed software
RUN apt update && \
    apt install -y \
        ssh \
        openssh-server \
        screen \
        vim \
        logrotate \
        netcat-openbsd \
        git \
        zsh \
        zsh-autosuggestions \
        zsh-syntax-highlighting \
        curl \
        tmux

# Install ohmyzsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Clone config files
RUN git clone https://github.com/simonhoellein/dotfiles.git /root/dotfiles && \
    cp -r /root/dotfiles/. /root/.

RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Add SSH-Keys from github
RUN mkdir -p /root/.ssh/ && \
    touch /root/.ssh/authorized_keys && \
    curl https://github.com/simonhoellein.keys >> /root/.ssh/authorized_keys

# Add sshd config
ADD config/openssh-server/sshd_config /etc/ssh/sshd_config

COPY start.sh /root/start.sh

# Expose SSH Port for udp and tcp
EXPOSE 22/tcp
EXPOSE 22/udp

ENTRYPOINT [ "/root/start.sh" ]

# Labels
LABEL org.opencontainers.image.authors="simon@shoellein.de"
LABEL description="ssh jumphost server with enabled shell and some utilitys"