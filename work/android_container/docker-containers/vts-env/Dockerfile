FROM ubuntu:18.04

ARG current_user=user

RUN mkdir -p /run/systemd && echo 'docker' > /run/systemd/container
RUN sed -i 's/^#\s*\(deb.*universe\)$/\1/g' /etc/apt/sources.list

# Add current user.
RUN useradd -s /bin/bash $current_user

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

# Whatever's needed for VTS
RUN apt-get -y update && apt-get -y install \ 
    fastboot adb openjdk-8-jdk \
    python3 \
    python3-dev \
    python3-pip \
    python3-protobuf \
    python3-virtualenv \
    python3-jinja2 \
    python3-xlrd \
    python-virtualenv \
    python-pip \
    python-protobuf \
    protobuf-compiler \
    unzip \
    wget \
  && rm -rf /var/lib/apt/lists/* \
  && wget https://dl.google.com/android/repository/platform-tools-latest-linux.zip \
  && unzip -d /usr/local/sbin platform-tools-latest-linux.zip \
  && wget -O /usr/local/sbin/adb https://raw.githubusercontent.com/NicolasBernaerts/ubuntu-scripts/master/android/adb \
  && wget -O /usr/local/sbin/fastboot https://raw.githubusercontent.com/NicolasBernaerts/ubuntu-scripts/master/android/fastboot \
  && chmod +x /usr/local/sbin/adb /usr/local/sbin/fastboot


# Set up UDEV rules
RUN mkdir -p /etc/udev/rules.d && echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="8087", MODE="0666", GROUP="plugdev"' > /etc/udev/rules.d/51-android.rules

# Add user to the plugdev group
RUN usermod -aG plugdev $current_user

RUN rm -rf /var/lib/apt/lists/*
