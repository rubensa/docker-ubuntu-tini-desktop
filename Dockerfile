FROM rubensa/ubuntu-tini-x11
LABEL author="Ruben Suarez <rubensa@gmail.com>"

# Tell docker that all future commands should be run as root
USER root

# Set root home directory
ENV HOME=/root

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Configure apt
RUN apt-get update

# Add calibre
RUN echo "# Installing calibre..." \
  && apt-get -y install --no-install-recommends calibre 2>&1

# Install chrome dependencies
RUN apt-get -y install --no-install-recommends libx11-xcb1 2>&1
# Add google chrome repo
RUN mkdir -p /etc/apt/keyrings/ \
  && curl -sSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /etc/apt/keyrings/google.gpg  \
  && printf "deb [signed-by=/etc/apt/keyrings/google.gpg] https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
  # Install google chrome
  && echo "# Installing chrome..." \
  && apt-get update && apt-get -y install --no-install-recommends google-chrome-stable 2>&1;

# Install deluge dependencies
RUN apt-get -y install --no-install-recommends software-properties-common 2>&1
# Add Deluge
RUN echo "# Installing deluge..." \
  #
  # Add Deluge repo
  && add-apt-repository -y ppa:deluge-team/stable \
  && apt-get update && apt-get -y install --no-install-recommends deluge 2>&1

# Install Appimage and draw.io dependencies
RUN apt-get -y install --no-install-recommends fuse libfuse2 libnss3 2>&1
# Add draw.io Appimage (https://github.com/jgraph/drawio-desktop/releases)
ARG DRAWIO_VERSION=21.5.1
# Add draw.io
RUN echo "# Installing draw.io..."
ADD https://github.com/jgraph/drawio-desktop/releases/download/v${DRAWIO_VERSION}/drawio-x86_64-${DRAWIO_VERSION}.AppImage /usr/local/bin/draw.io
# Make Appimage executable
RUN chmod +rx /usr/local/bin/draw.io


# Add filezilla
RUN echo "# Installing filezilla..." \
  && apt-get -y install --no-install-recommends filezilla 2>&1

# Install Appimage and GIMP dependencies
RUN apt-get -y install --no-install-recommends fuse libfuse2 libopenraw7 2>&1
# Add GIMP Appimage (https://github.com/aferrero2707/gimp-appimage/releases)
ARG GIMP_VERSION=2.10.22
# Add GIMP
RUN echo "# Installing gimp..."
ADD https://github.com/aferrero2707/gimp-appimage/releases/download/continuous/GIMP_AppImage-release-${GIMP_VERSION}-withplugins-x86_64.AppImage /usr/local/bin/gimp
# Make Appimage executable
RUN chmod +rx /usr/local/bin/gimp

# Install Appimage and inkscape dependencies
RUN apt-get -y install --no-install-recommends fuse libfuse2 2>&1
# Inkscape Appimage GitLab build job ID (INKSCAPE_1_2_2 https://gitlab.com/inkscape/inkscape/-/tags)
ARG INKSCAPE_JOBID=3415251731
# Add Inkscape
RUN echo "# Installing inkscape..."
ADD https://gitlab.com/inkscape/inkscape/-/jobs/${INKSCAPE_JOBID}/artifacts/download /tmp/Inkscape.zip
# Inkscape Appimage
RUN unzip /tmp/Inkscape.zip -d /tmp \
  && find /tmp -maxdepth 1 -type f -name 'Inkscape*.AppImage' -exec mv {} /usr/local/bin/inkscape \; \
  && rm /tmp/Inkscape* \
  #
  # Make Appimage executable
  && chmod +rx /usr/local/bin/inkscape

# Install Krita dependencies
RUN apt-get -y install --no-install-recommends fuse libfuse2 2>&1
# Add Krita (https://krita.org/en/download/krita-desktop/)
ARG KRITA_VERSION=5.1.5
# Add Krita
RUN echo "# Installing krita..."
ADD https://download.kde.org/stable/krita/${KRITA_VERSION}/krita-${KRITA_VERSION}-x86_64.appimage /usr/local/bin/krita
# Make Appimage executable
RUN chmod +rx /usr/local/bin/krita

# Install libreoffice dependencies
RUN apt-get -y install --no-install-recommends software-properties-common default-jre 2>&1
# Add LibreOffice
RUN echo "# Installing libreoffice..." \
  #
  # Add LibreOffice repo
  && add-apt-repository -y ppa:libreoffice/ppa \
  && apt-get update && apt-get -y install --no-install-recommends libreoffice libreoffice-java-common 2>&1

# Install meld dependencies
RUN apt-get -y install --no-install-recommends adwaita-icon-theme-full 2>&1
# Add meld
RUN echo "# Installing meld..." \
  && apt-get -y install --no-install-recommends meld 2>&1

# Install pencil dependencies
RUN apt-get -y install --no-install-recommends libnss3 libxss1 wget 2>&1
# Pencil (https://pencil.evolus.vn/Downloads.html)
ARG PENCIL_VERSION=3.1.1.ga
# Add Pencil
RUN echo "# Installing pencil..." \
  #
  # Pencil Ubuntu 64 DEB Package
  && wget -O pencil.deb https://pencil.evolus.vn/dl/V${PENCIL_VERSION}/Pencil_${PENCIL_VERSION}_amd64.deb \
  && apt-get -y install ./pencil.deb \
  && rm ./pencil.deb

# Add remmina
RUN echo "# Installing remmina..." \
  && apt-get -y install --no-install-recommends remmina 2>&1

# NOTE: Slack depends on chrome to be installed
# Slack (https://slack.com/intl/es-es/release-notes/linux)
ARG SLACK_VERSION=4.32.127
# Add Slack
RUN echo "# Installing slack..." \
  && curl -o slack-desktop-amd64.deb -sSL https://downloads.slack-edge.com/releases/linux/${SLACK_VERSION}/prod/x64/slack-desktop-${SLACK_VERSION}-amd64.deb \
  && apt-get -y install ./slack-desktop-amd64.deb \
  && rm ./slack-desktop-amd64.deb

# Add thunderbird
RUN echo "# Installing thunderbird..." \
  && apt-get -y install --no-install-recommends thunderbird 2>&1

# Install vlc dependencies
RUN apt-get -y install --no-install-recommends software-properties-common libavcodec-extra libxcb-xinerama0 2>&1
# Add VideoLAN
RUN echo "# Installing vlc..." \
  #
  # Add VideoLAN repo
  && add-apt-repository -y ppa:videolan/master-daily \
  && apt-get update && apt-get -y install --no-install-recommends vlc vlc-plugin-access-extra 2>&1

# Add Zoom (https://support.zoom.us/hc/en-us/articles/205759689-Release-notes-for-Linux)
ARG ZOOM_VERSION=5.15.2.4260
RUN echo "# Installing zoom..." \
  && curl -o zoom.deb -sSL https://zoom.us/client/${ZOOM_VERSION}/zoom_amd64.deb \
  && apt-get -y install ./zoom.deb \
  && rm ./zoom.deb

# Add Discord (https://discord.com/download)
ARG DISCORD_VERSION=0.0.27
ADD https://dl.discordapp.net/apps/linux/${DISCORD_VERSION}/discord-${DISCORD_VERSION}.tar.gz /tmp/discord.tar.gz
RUN echo "# Installing Discord..." \
  && tar xvfz /tmp/discord.tar.gz --directory /opt \
  && rm /tmp/discord.tar.gz \
  && ln -s /opt/Discord/Discord /usr/local/bin/Discord

# Install OBS Studio dependencies (and Virtual camera support)
RUN apt-get -y install --no-install-recommends software-properties-common v4l2loopback-dkms 2>&1
# Add OBS Studio repo
RUN add-apt-repository ppa:obsproject/obs-studio \
  # Install OBS Studio
  && echo "# Installing OBS Studio..." \
  && apt-get update && apt-get -y install --no-install-recommends obs-studio 2>&1;

# Clean up apt
RUN apt-get autoremove -y \
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
