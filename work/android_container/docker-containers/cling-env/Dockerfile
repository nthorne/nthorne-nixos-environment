FROM ubuntu:16.04

CMD /usr/local/sbin/cling-wrapper

ARG current_user=user

# Add the current user to the system
RUN useradd -s /bin/bash $current_user

# Set a convenient root password
RUN echo "root:root" | chpasswd

RUN mkdir -p /run/systemd && echo 'docker' > /run/systemd/container
RUN sed -i 's/^#\s*\(deb.*universe\)$/\1/g' /etc/apt/sources.list

# Create the wrapper script
RUN echo "#!/bin/bash" >> /usr/local/sbin/cling-wrapper
RUN echo "cling -w \$(find . -name \\*include -exec echo '-I {}' \;)" >> /usr/local/sbin/cling-wrapper
RUN chmod ugo+rwx /usr/local/sbin/cling-wrapper

# Make sure that pre-installed packages are up to date.
# NOTE: Removing /var/lib/apt/lists is for minimizing layer/images size.
RUN apt-get -y update && apt-get -fy install   && rm -rf /var/lib/apt/lists/*

# Install the needed packages
RUN apt-get -y update && apt-get -y install \
    wget bzip2 gcc dpkg-dev binutils \
    && wget https://root.cern.ch/download/cling/cling_2019-03-06_ubuntu16.tar.bz2 \
    && tar xvf cling_2019-03-06_ubuntu16.tar.bz2 --strip-components=1 -C /usr/local

RUN rm -rf /var/lib/apt/lists/*
