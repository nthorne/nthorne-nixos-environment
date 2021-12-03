FROM nexus.android.delphiauto.net:5050/ubuntu:18.04
# TODO check if lib32z-dev can be removed
RUN dpkg --add-architecture i386 \
  && export DEBIAN_FRONTEND=noninteractive \
  && echo "*********** Install build dependencies" \
  && apt-get clean \
  && apt-get update \
  && apt-get install -y \
    acpica-tools=20180105-1 \
    android-tools-fsutils=5.1.1.r38-1.1 \
    bc=1.07.1-2 \
    bison=2:3.0.4.dfsg-1build1 \
    bsdmainutils=11.1.2ubuntu1 \
    build-essential=12.4ubuntu1 \
    cgpt=0~R63-10032.B-3 \
    curl=7.58.0-2ubuntu3.13 \
    dirmngr=2.2.4-1ubuntu1.4 \
    dos2unix=7.3.4-3 \
    dosfstools=4.1-1 \
    flex=2.6.4-6 \
    g++-multilib=4:7.4.0-1ubuntu2.3 \
    gawk=1:4.1.4+dfsg-1build1 \
    gcc-multilib=4:7.4.0-1ubuntu2.3 \
    gettext=0.19.8.1-6ubuntu0.3 \
    git=1:2.17.1-1ubuntu0.8 \
    gnupg=2.2.4-1ubuntu1.4 \
    gnupg-l10n=2.2.4-1ubuntu1.4 \
    gnupg-utils=2.2.4-1ubuntu1.4 \
    gperf=3.1-1 \
    gpg=2.2.4-1ubuntu1.4 \
    gpg-agent=2.2.4-1ubuntu1.4 \
    gpg-wks-client=2.2.4-1ubuntu1.4 \
    gpg-wks-server=2.2.4-1ubuntu1.4 \
    gpgconf=2.2.4-1ubuntu1.4 \
    gpgsm=2.2.4-1ubuntu1.4 \
    imagemagick=8:6.9.7.4+dfsg-16ubuntu6.9 \
    kmod=24-1ubuntu3.5 \
    lib32ncurses5-dev=6.1-1ubuntu1.18.04 \
    lib32z-dev \
    libc6=2.27-3ubuntu1.4 \
    libc6-dev=2.27-3ubuntu1.4 \
    libc6-dev-i386=2.27-3ubuntu1.4 \
    libc6:i386=2.27-3ubuntu1.4 \
    libelf-dev=0.170-0.4ubuntu0.1 \
    libfontconfig1=2.12.6-0ubuntu2 \
    libgl1-mesa-dev=20.0.8-0ubuntu1~18.04.1 \
    liblz4-tool=0.0~r131-2ubuntu3 \
    libncurses5=6.1-1ubuntu1.18.04 \
    libncurses5:i386=6.1-1ubuntu1.18.04 \
    libreadline-dev:i386=7.0-3 \
    libsm6=2:1.2.2-1 \
    libsqlite3-dev=3.22.0-1ubuntu0.4 \
    libssl-dev=1.1.1-1ubuntu2.1~18.04.9 \
    libstdc++6=8.4.0-1ubuntu1~18.04 \
    libstdc++6:i386=8.4.0-1ubuntu1~18.04 \
    libtinfo-dev=6.1-1ubuntu1.18.04 \
    libx11-dev=2:1.6.4-3ubuntu0.3 \
    libx11-dev:i386=2:1.6.4-3ubuntu0.3 \
    libxcb-icccm4=0.4.1-1ubuntu1 \
    libxcb-image0=0.4.0-1build1 \
    libxcb-keysyms1=0.4.0-1 \
    libxcb-render-util0=0.3.9-1 \
    libxcb-xinerama0=1.13-2~ubuntu18.04 \
    libxkbcommon-x11-0=0.8.2-1~ubuntu18.04.1 \
    libxi6=2:1.7.9-1 \
    libxml2-utils=2.9.4+dfsg1-6.1ubuntu1.3 \
    libxrender1=1:0.9.10-1 \
    mingw-w64=5.0.3-1 \
    mtools=4.0.18-2ubuntu1 \
    nasm=2.13.02-0.1 \
    openjdk-8-jdk=8u292-b10-0ubuntu1~18.04 \
    openssh-server=1:7.6p1-4ubuntu0.3 \
    python-libxml2=2.9.4+dfsg1-6.1ubuntu1.3 \
    python-mako=1.0.7+ds1-1 \
    python-markdown=2.6.9-1 \
    python-pip=9.0.1-2.3~ubuntu1.18.04.4 \
    python-pystache=0.5.4-6 \
    python3=3.6.7-1~18.04 \
    python3-jinja2=2.10-1ubuntu0.18.04.1 \
    python3-pip=9.0.1-2.3~ubuntu1.18.04.4 \
    python3-xlrd=1.1.0-1 \
    rsync=3.1.2-2.1ubuntu1.1 \
    squashfs-tools=1:4.3-6ubuntu0.18.04.1 \
    tesseract-ocr=4.00~git2288-10f4998a-2 \
    tofrodos=1.7.13+ds-3 \
    unzip=6.0-21ubuntu1.1 \
    vim=2:8.0.1453-1ubuntu1.4 \
    vim-common=2:8.0.1453-1ubuntu1.4 \
    wget=1.19.4-1ubuntu2.2 \
    x11proto-core-dev=2018.4-4 \
    xsltproc=1.1.29-5ubuntu0.2 \
    zip=3.0-11build1 \
    zlib1g-dev=1:1.2.11.dfsg-0ubuntu2 \
  && echo "*********** Install Python3 module cryptography" \
    && wget https://github.com/pyca/cryptography/archive/3.1.tar.gz -P /tmp \
    && tar -xvf /tmp/3.1.tar.gz -C /tmp \
    && cd /tmp/cryptography-3.1 \
    && python3 setup.py install \
  && echo "*********** Install ccache" \
    && wget https://github.com/ccache/ccache/releases/download/v3.7.4/ccache-3.7.4.tar.gz -P /tmp \
    && tar -xvf /tmp/ccache-3.7.4.tar.gz -C /tmp \
    && cd /tmp/ccache-3.7.4 \
    && ./configure \
    && make \
    && make install \
  && echo "*********** Install s6-overlay" \
    && wget https://github.com/just-containers/s6-overlay/releases/download/v2.0.0.1/s6-overlay-amd64.tar.gz -P /tmp \
    && gunzip -c /tmp/s6-overlay-amd64.tar.gz | tar -xf - -C / \
  && echo "*********** Update lz4" \
    && curl -L https://github.com/lz4/lz4/archive/v1.9.3.tar.gz | tar xzv -C /tmp \
    && cd /tmp/lz4-1.9.3 \
    && make \
    && PREFIX="/usr" make uninstall \
    && PREFIX="/usr" make install \
  && echo "*********** Install lz4 python module (python bindings to lz4 library)" \
    && python3 -m pip install --upgrade pip \
    && python3 -m pip install 'lz4==2.2.1' \
  && echo "*********** Create user aosp_builder" \
    && useradd -u 911 -U -d /config -s /bin/false aosp_builder \
    && usermod -G users aosp_builder \
  && echo "*********** Setting up UDEV rules" \
    && usermod -aG plugdev aosp_builder \
    && mkdir -p /etc/udev/rules.d && echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="8087", MODE="0666", GROUP="plugdev"' > /etc/udev/rules.d/51-android.rules \
  && echo "*********** Seting a known root password" \
    && echo "root:root" | chpasswd \
  && echo "*********** Cleanup" \
    && apt-get clean \
    && rm -rf /tmp/* \
    && rm -rf /var/lib/apt/lists/*

# Enable ccache by default
VOLUME /opt/ccache
ENV CCACHE_DIR=/opt/ccache
ENV USE_CCACHE=1
ENV CCACHE_EXEC=/usr/local/bin/ccache

COPY bin/adduser-aosp_builder /etc/cont-init.d/adduser-aosp_builder
ENV HOME=/home/aosp_builder
WORKDIR /home/aosp_builder/aosp_src
ENTRYPOINT ["/init", "s6-setuidgid", "aosp_builder"]
CMD ["/bin/bash"]
