FROM ubuntu:16.04

# Don't use USER, as we want to run as toot.
ARG current_user=nthorne
ARG id=1000
ARG HOME=/home/${current_user}
WORKDIR ${HOME}

RUN mkdir -p /run/systemd && echo 'docker' > /run/systemd/container
RUN sed -i 's/^#\s*\(deb.*universe\)$/\1/g' /etc/apt/sources.list

# Add current user.
RUN useradd -s /bin/bash -d ${HOME} -u 1000 -g 100 -m ${current_user}

# Set a known root password
RUN echo "root:root" | chpasswd

# Install necessities beyond what's in the pulled Dockerfile
# NOTE: I also had to symlink in /run/current-system/sw/bin/pwd to /bin/pwd
RUN apt-get -y update && apt-get -y install \
    bc \
    coreutils \
    kmod \
    libssl-dev \
  && rm -rf /var/lib/apt/lists/*


RUN dpkg --add-architecture i386 && apt-get update && apt-get install -qy \
    file \
    gawk \
    wget \
    git-core \
    diffstat \
    unzip \
    texinfo \
    gcc-multilib \
    build-essential \
    chrpath \
    socat \
    cpio \
    python \
    python3 \
    python3-pip \
    python3-pexpect \
    xz-utils \
    debianutils \
    iputils-ping \
    libsdl1.2-dev \
    default-jdk \
    curl \
    ca-certificates \
    xterm \
    locales \
    software-properties-common \
    make \
    xsltproc \
    docbook-utils \
    fop \
    dblatex \
    xmlto \
    python-git \
    realpath \
    gettext \
    zlib1g:i386 \
    apt-transport-https \
    m4
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key |  apt-key add - \
    && apt-add-repository --yes "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-6.0 main" \
    && apt-get update && apt-get install --no-install-recommends -qy \
    clang \
    clang-6.0 \
    lldb-6.0 \
    llvm \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN wget -O /usr/local/bin/repo http://storage.googleapis.com/git-repo-downloads/repo && \
    chmod a+x /usr/local/bin/repo

# Set up UDEV rules
RUN mkdir -p /etc/udev/rules.d && echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="8087", MODE="0666", GROUP="plugdev"' > /etc/udev/rules.d/51-android.rules
RUN mkdir -p /etc/udev/rules.d && echo 'SUBSYSTEM=="usb", ATTRS{idVendor}=="05c6", MODE="0666", GROUP="plugdev"' > /etc/udev/rules.d/52-oneplus.rules
RUN mkdir -p /etc/udev/rules.d && echo 'SUBSYSTEM=="usb", ATTRS{idVendor}=="04e8", MODE="0666", GROUP="plugdev"' > /etc/udev/rules.d/52-oneplus.rules

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen
ENV LANG en_US.UTF-8

# make /bin/sh symlink to bash instead of dash
RUN echo "dash dash/sh boolean false" | debconf-set-selections && \
    dpkg-reconfigure dash

# We need this because of this https://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/
# Here is solution https://engineeringblog.yelp.com/2016/01/dumb-init-an-init-for-docker.html
RUN wget -O /usr/local/bin/dumb-init \
    https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64 \
    && chmod +x /usr/local/bin/dumb-init
# Runs "/usr/bin/dumb-init -- /my/script --with --args"
ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]
