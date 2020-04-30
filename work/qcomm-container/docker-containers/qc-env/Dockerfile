FROM ubuntu:16.04

ARG USER=nthorne
ARG HOME=/home/nthorne

RUN mkdir -p /run/systemd && echo 'docker' > /run/systemd/container
RUN sed -i 's/^#\s*\(deb.*universe\)$/\1/g' /etc/apt/sources.list

# Add current user.
RUN useradd -s /bin/bash -d ${HOME} -u 1000 -g 100 -m ${USER}

# Set a known root password
RUN echo "root:root" | chpasswd

# Make sure that pre-installed packages are up to date.
# NOTE: Removing /var/lib/apt/lists is for minimizing layer/images size.
RUN apt-get -y update && apt-get -fy install \
  && rm -rf /var/lib/apt/lists/*

# Install nice-to-haves.
RUN apt-get -y update && apt-get -y install \
    gawk \
    gdb \
    inotify-tools \
    tmux \
    tmuxinator \
  && rm -rf /var/lib/apt/lists/*

# Install android development tools.
RUN apt-get -y update && apt-get -y install \ 
    bc \
    bison \
    build-essential \
    ca-certificates \
    ccache \
    chrpath \
    cpio \
    curl \
    dblatex \
    debianutils \
    default-jdk \
    diffstat \
    docbook-utils \
    fastboot adb openjdk-8-jdk \
    file \
    flex \
    fop \
    g++-multilib \
    gcc-multilib \
    gettext \
    vim-common \
    git-core \
    gnupg \
    gperf \
    iputils-ping \
    libsdl1.2-dev \
    lib32ncurses5-dev \
    lib32z-dev \
    libc6-dev-i386 \
    libgl1-mesa-dev \
    liblz4-tool \
    libssl-dev \
    libx11-dev \
    libxml-simple-perl \
    libxml2-utils \
    locales \
    make \
    openjdk-8-jre \
    openjdk-8-jre-headless \
    protobuf-compiler \
    python \
    python-dev \
    python-git \
    python-mako \
    python-pip \
    python-protobuf \
    python-virtualenv \
    python3 \
    python3-jinja2 \
    python3-pexpect \
    python3-pip \
    python3-xlrd \
    qemu \
    qemu-utils \
    socat \
    software-properties-common \
    sshfs \
    texinfo \
    unzip \
    wget \
    x11proto-core-dev \
    xmlto \
    xsltproc \
    xz-utils \
    zip \
    zlib1g-dev \
  && wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key |  apt-key add - \
  && apt-add-repository --yes "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-6.0 main" \
  && apt-get update && apt-get install --no-install-recommends -qy \
  clang \
  clang-6.0 \
  lldb-6.0 \
  llvm \
  && rm -rf /var/lib/apt/lists/* \
  && wget https://dl.google.com/android/repository/platform-tools-latest-linux.zip \
  && unzip -d /usr/local/sbin platform-tools-latest-linux.zip \
  && wget -O /usr/local/sbin/adb https://raw.githubusercontent.com/NicolasBernaerts/ubuntu-scripts/master/android/adb \
  && wget -O /usr/local/sbin/fastboot https://raw.githubusercontent.com/NicolasBernaerts/ubuntu-scripts/master/android/fastboot \
  && chmod +x /usr/local/sbin/adb /usr/local/sbin/fastboot


# Set up UDEV rules
RUN mkdir -p /etc/udev/rules.d && echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="8087", MODE="0666", GROUP="plugdev"' > /etc/udev/rules.d/51-android.rules
RUN mkdir -p /etc/udev/rules.d && echo 'SUBSYSTEM=="usb", ATTRS{idVendor}=="05c6", MODE="0666", GROUP="plugdev"' > /etc/udev/rules.d/52-oneplus.rules
RUN mkdir -p /etc/udev/rules.d && echo 'SUBSYSTEM=="usb", ATTRS{idVendor}=="04e8", MODE="0666", GROUP="plugdev"' > /etc/udev/rules.d/52-oneplus.rules

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen
ENV LANG en_US.UTF-8

# make /bin/sh symlink to bash instead of dash
RUN echo "dash dash/sh boolean false" | debconf-set-selections && \
    dpkg-reconfigure dash

# Add user to the plugdev group
RUN usermod -aG plugdev ${USER}

RUN rm -rf /var/lib/apt/lists/*

# Needed for the QComm env
RUN ln -sf /bin/bash /bin/sh
RUN dpkg-reconfigure locales && locale-gen en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
