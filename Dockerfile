FROM rubensa/ubuntu-tini-x11
LABEL author="Ruben Suarez <rubensa@gmail.com>"

# Tell docker that all future commands should be run as root
USER root

# Set root home directory
ENV HOME=/root

# Add GIMP Appimage
ARG GIMP_VERSION=GIMP_AppImage-release-2.10.8-withplugins-x86_64
ADD https://github.com/aferrero2707/gimp-appimage/releases/download/continuous/${GIMP_VERSION}.AppImage /usr/local/bin/gimp

# Add InskScape Appimage
#ARG INKSCAPE_VERSION=Inkscape-0.92.3%2B68.glibc2.15-x86_64
#ADD https://bintray.com/probono/AppImages/download_file?file_path=${INKSCAPE_VERSION}.AppImage /usr/local/bin/inkscape

# suppress GTK warnings about accessibility
# (WARNING **: Couldn't connect to accessibility bus: Failed to connect to socket /tmp/dbus-dw0fOAy4vj: Connection refused)
ENV NO_AT_BRIDGE 1

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Configure apt and install packages
RUN apt-get update \
    # 
    # Install software and needed libraries
    && apt-get -y install --no-install-recommends curl software-properties-common gnupg fuse  qtwayland5 libavcodec-extra libcanberra-gtk-module libcanberra-gtk3-module qml-module-qtquick-controls libgconf-2-4 libxkbfile1 2>&1 \
    #
    # Add Repos
    #
    # Chrome repo
    && printf "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
    && curl -O https://dl.google.com/linux/linux_signing_key.pub \
    && apt-key add linux_signing_key.pub \
    && rm linux_signing_key.pub \
    #
    # Thunderbird repo
    && sudo add-apt-repository -y ppa:mozillateam/ppa \
    #
    # VideoLAN repo
    && add-apt-repository -y ppa:videolan/master-daily \
    #
    # Inkscape repo
    && add-apt-repository -y ppa:inkscape.dev/stable \
    #
    # Krita repo
    && add-apt-repository -y ppa:kritalime/ppa \
    #
    # LibreOffice repo
    && add-apt-repository -y ppa:libreoffice/ppa \
    #
    # Deluge repo
    && add-apt-repository -y ppa:deluge-team/stable \
    #
    # Install software
    && apt-get -y install thunderbird google-chrome-stable vlc inkscape krita libreoffice deluge filezilla remmina calibre \
    #
    # Make Appimages executable
    && chmod +rx /usr/local/bin/gimp \
    #&& chmod +rx /usr/local/bin/inkscape \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=

# Tell docker that all future commands should be run as the non-root user
USER ${USER_NAME}

# Set user home directory (see: https://github.com/microsoft/vscode-remote-release/issues/852)
ENV HOME /home/$USER_NAME
