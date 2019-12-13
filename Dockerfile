FROM rubensa/ubuntu-tini-x11
LABEL author="Ruben Suarez <rubensa@gmail.com>"

# Tell docker that all future commands should be run as root
USER root

# Set root home directory
ENV HOME=/root

# Add GIMP Appimage
ARG GIMP_VERSION=release-2.10.14
ADD https://github.com/aferrero2707/gimp-appimage/releases/download/continuous/GIMP_AppImage-${GIMP_VERSION}-withplugins-x86_64.AppImage /usr/local/bin/gimp

# Add draw.io Appimage
ARG DRAWIO_VERSION=12.3.2
ADD https://github.com/jgraph/drawio-desktop/releases/download/v${DRAWIO_VERSION}/draw.io-x86_64-${DRAWIO_VERSION}.AppImage /usr/local/bin/draw.io

# Set Microsoft Teams version
ARG TEAMS_VERSION=1.2.00.32451

# Set VSCode version
ARG VSCODE_VERSION=1.41.0

# suppress GTK warnings about accessibility
# (WARNING **: Couldn't connect to accessibility bus: Failed to connect to socket /tmp/dbus-dw0fOAy4vj: Connection refused)
ENV NO_AT_BRIDGE 1

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Configure apt and install packages
RUN apt-get update && apt-get -y upgrade \
    # 
    # Install software and needed libraries
    && apt-get -y install --no-install-recommends curl software-properties-common gnupg fuse qtwayland5 libavcodec-extra libcanberra-gtk-module libcanberra-gtk3-module qml-module-qtquick-controls libgconf-2-4 libxkbfile1 libxcb-xinerama0 2>&1 \
    #
    # Add Repos
    #
    # Chrome repo
    && printf "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
    && curl -L -O https://dl.google.com/linux/linux_signing_key.pub \
    && apt-key add linux_signing_key.pub \
    && rm linux_signing_key.pub \
    #
    # Thunderbird repo
    && add-apt-repository -y ppa:mozillateam/ppa \
    #
    # VideoLAN repo
    && add-apt-repository -y ppa:videolan/master-daily \
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
    && apt-get -y install thunderbird google-chrome-stable vlc krita libreoffice deluge filezilla remmina calibre \
    #
    # Install Microsoft Teams
    && curl -O https://packages.microsoft.com/repos/ms-teams/pool/main/t/teams/teams_${TEAMS_VERSION}_amd64.deb \
    && dpkg -i teams_${TEAMS_VERSION}_amd64.deb \
    && rm teams_${TEAMS_VERSION}_amd64.deb \
    #
    # Install VSCode
    && curl -L -o code-stable-${VSCODE_VERSION}.tar.gz https://update.code.visualstudio.com/${VSCODE_VERSION}/linux-x64/stable \
    && tar -xf code-stable-${VSCODE_VERSION}.tar.gz -C /opt \
    && rm code-stable-${VSCODE_VERSION}.tar.gz \
    #
    # Assign group folder ownership
    && chgrp -R ${GROUP_NAME} /opt/VSCode-linux-x64 \
    #
    # Set the segid bit to the folder
    && chmod -R g+s /opt/VSCode-linux-x64 \
    #
    # Give write and exec acces so anyobody can use it
    && chmod -R ga+wX /opt/VSCode-linux-x64 \
    #
    # Link to standard binary PATH
    && ln -s /opt/VSCode-linux-x64/code /usr/local/bin/code \
    #
    # Inkscape Appimage (INKSCAPE_1_0_BETA2)
    && curl -L -o Inkscape.zip https://gitlab.com/inkscape/inkscape/-/jobs/368309106/artifacts/download \
    && unzip Inkscape.zip \
    && find . -maxdepth 1 -type f -name 'Inkscape*.AppImage' -exec mv {} /usr/local/bin/inkscape \; \
    && rm Inkscape* \
    #
    # Make Appimages executable
    && chmod +rx /usr/local/bin/gimp \
    && chmod +rx /usr/local/bin/draw.io \
    && chmod +rx /usr/local/bin/code \
    && chmod +rx /usr/local/bin/inkscape \
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
ENV HOME /home/${USER_NAME}

# Set default working directory to user home directory
WORKDIR ${HOME}
