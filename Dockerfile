FROM openjdk:8
LABEL maintainer="jfloff@inesc-id.pt"

###################
# This Dockerfile was based on the following Dockerfiles
# - docker-lineageos: existing unoptimized image
#    https://github.com/AnthoDingo/docker-lineageos/blob/autobuild/Dockerfile
#

# default user
ENV USER=lineageos
ENV \
    # base dir
    BASE_DIR=/home/$USER \
    # device configuration dir
    DEVICE_CONFIGS_DIR=/home/device-config

# install packages
RUN set -ex ;\
    apt-get update && apt-get install -y --no-install-recommends \
          # install sdk
          # https://wiki.lineageos.org/devices/klte/build#install-the-build-packages
          android-sdk-platform-tools-common \
          android-tools-adb \
          android-tools-fastboot \
          # install packages
          # https://wiki.lineageos.org/devices/klte/build#install-the-build-packages
          bc \
          bison \
          build-essential \
          flex \
          g++-multilib \
          gcc-multilib \
          git \
          gnupg \
          gperf \
          imagemagick \
          lib32ncurses5-dev \
          lib32readline-dev \
          lib32z1-dev \
          libesd0-dev \
          liblz4-tool \
          libncurses5-dev \
          libsdl1.2-dev \
          libssl-dev \
          libwxgtk3.0-dev \
          libxml2 \
          libxml2-utils \
          lzop \
          pngcrush \
          rsync \
          schedtool \
          squashfs-tools \
          xsltproc \
          zip \
          zlib1g-dev \
          # extra packages
          # for git-repo from google
          python \
          # for ps command
          procps \
          # no less on debian *gasp!*
          less \
          # so we have an editor inside the container
          vim \
          # has 'col' package needed for 'breakfast'
	      bsdmainutils \
          # we can't build kernel on root (like docker runs)
          # we add these so we have a non-root user
          fakeroot \
          sudo \
          gosu \
          ;\
    rm -rf /var/lib/apt/lists/*

# run config in a seperate layer so we cache it
RUN set -ex ;\
    # Android Setup
    # create paths: https://wiki.lineageos.org/devices/klte/build#create-the-directories
    curl https://storage.googleapis.com/git-repo-downloads/repo > /usr/bin/repo ;\
    chmod a+x /usr/bin/repo ;\
    # source init when any bash is called (which includes the lineageos script)
    echo "source /etc/profile.d/init.sh" >> /etc/bash.bashrc

# copy default configuration into container
COPY default.env init.sh /etc/profile.d/
# copy script and config vars
COPY lineageos /bin
# copy dir with several PRed device configurations
COPY device-config $DEVICE_CONFIGS_DIR

# copy entrypoint into conatiner
COPY entrypoint.sh /usr/local/bin/

# set entrypoint
ENTRYPOINT ["bash", "/usr/local/bin/entrypoint.sh"]

# use bash
CMD ["/bin/bash"]
