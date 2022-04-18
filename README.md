# Docker image with some GUI apps

This is a Docker image based on [rubensa/ubuntu-tini-x11](https://github.com/rubensa/docker-ubuntu-tini-x11) and includes some GUI applications.

## Building

You can build the image like this:

```
#!/usr/bin/env bash

docker build --no-cache \
  -t "rubensa/ubuntu-tini-desktop" \
  --label "maintainer=Ruben Suarez <rubensa@gmail.com>" \
  .
```

## Running

You can run the container like this (change --rm with -d if you don't want the container to be removed on stop):

```
#!/usr/bin/env bash

# Get current user UID
USER_ID=$(id -u)
# Get current user main GUID
GROUP_ID=$(id -g)
# Built in user name
USER_NAME=user

prepare_docker_timezone() {
  # https://www.waysquare.com/how-to-change-docker-timezone/
  ENV_VARS+=" --env=TZ=$(cat /etc/timezone)"
}

prepare_docker_user_and_group() {
  RUNNER+=" --user=${USER_ID}:${GROUP_ID}"
}

prepare_docker_from_docker() {
  # Docker
  if [ -S /var/run/docker.sock ]; then
    MOUNTS+=" --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker-host.sock"
  fi
}

prepare_docker_dbus_host_sharing() {
  # To access DBus you ned to start a container without an AppArmor profile
  SECURITY+=" --security-opt apparmor:unconfined"
  # https://github.com/mviereck/x11docker/wiki/How-to-connect-container-to-DBus-from-host
  # User DBus
  MOUNTS+=" --mount type=bind,source=${XDG_RUNTIME_DIR}/bus,target=${XDG_RUNTIME_DIR}/bus"
  # System DBus
  MOUNTS+=" --mount type=bind,source=/run/dbus/system_bus_socket,target=/run/dbus/system_bus_socket"
  # User DBus unix socket
  # Prevent "gio:" "operation not supported" when running "xdg-open https://rubensa.eu.org"
  ENV_VARS+=" --env=DBUS_SESSION_BUS_ADDRESS=/dev/null"
}

prepare_docker_xdg_runtime_dir_host_sharing() {
  # XDG_RUNTIME_DIR defines the base directory relative to which user-specific non-essential runtime files and other file objects (such as sockets, named pipes, ...) should be stored.
  MOUNTS+=" --mount type=bind,source=${XDG_RUNTIME_DIR},target=${XDG_RUNTIME_DIR}"
  # XDG_RUNTIME_DIR
  ENV_VARS+=" --env=XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR}"
}

prepare_docker_sound_host_sharing() {
  # Sound device (ALSA - Advanced Linux Sound Architecture - support)
  [ -d /dev/snd ] && DEVICES+=" --device /dev/snd"
  # Pulseaudio unix socket (needs XDG_RUNTIME_DIR support)
  MOUNTS+=" --mount type=bind,source=${XDG_RUNTIME_DIR}/pulse,target=${XDG_RUNTIME_DIR}/pulse,readonly"
  # https://github.com/TheBiggerGuy/docker-pulseaudio-example/issues/1
  ENV_VARS+=" --env=PULSE_SERVER=unix:${XDG_RUNTIME_DIR}/pulse/native"
  RUNNER_GROUPS+=" --group-add audio"
}

prepare_docker_webcam_host_sharing() {
  # Allow webcam access
  for device in /dev/video*
  do
    if [[ -c $device ]]; then
      DEVICES+=" --device $device"
    fi
  done
  RUNNER_GROUPS+=" --group-add video"
}

prepare_docker_gpu_host_sharing() {
  # GPU support (Direct Rendering Manager)
  [ -d /dev/dri ] && DEVICES+=" --device /dev/dri"
  # VGA Arbiter
  [ -c /dev/vga_arbiter ] && DEVICES+=" --device /dev/vga_arbiter"
  # Allow nvidia devices access
  for device in /dev/nvidia*
  do
    if [[ -c $device ]]; then
      DEVICES+=" --device $device"
    fi
  done
}

prepare_docker_printer_host_sharing() {
  # CUPS (https://github.com/mviereck/x11docker/wiki/CUPS-printer-in-container)
  MOUNTS+=" --mount type=bind,source=/run/cups/cups.sock,target=/run/cups/cups.sock"
  ENV_VARS+=" --env CUPS_SERVER=/run/cups/cups.sock"
}

prepare_docker_ipc_host_sharing() {
  # Allow shared memory to avoid RAM access failures and rendering glitches due to X extesnion MIT-SHM
  EXTRA+=" --ipc=host"
}

prepare_docker_x11_host_sharing() {
   # X11 Unix-domain socket
  MOUNTS+=" --mount type=bind,source=/tmp/.X11-unix,target=/tmp/.X11-unix"
  ENV_VARS+=" --env=DISPLAY=unix${DISPLAY}"
  # Credentials in cookies used by xauth for authentication of X sessions
  if [ -f "${XAUTHORITY}" ]; then
    # IMPORTANT! You MUST run this command before starting the container to update the link
    if [ "${XAUTHORITY}" != "${HOME}/.Xauthority" ]; then
      ln -sf "${XAUTHORITY}" "${HOME}/.Xauthority"
    fi
    MOUNTS+=" --mount type=bind,source=${HOME}/.Xauthority,target=/home/${USER_NAME}/.Xauthority"
    ENV_VARS+=" --env=XAUTHORITY=/home/${USER_NAME}/.Xauthority"
  fi
}

prepare_docker_hostname_host_sharing() {
  # Using host hostname allows gnome-shell windows grouping
  EXTRA+=" --hostname `hostname`"
}

prepare_docker_nvidia_drivers_install() {
  # NVidia propietary drivers are needed on host for this to work
  if [ `command -v nvidia-smi` ]; then 
    NVIDIA_VERSION=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader)

    # On run, if you specify NVIDIA_VERSION the nvidia specified drivers version are installed
    ENV_VARS+=" --env=NVIDIA_VERSION=${NVIDIA_VERSION}"
  fi
}

prepare_docker_fuse_sharing() {
  # Fuse is needed by AppImage
  # The kernel requires SYS_ADMIN
  CAPABILITIES+=" --cap-add SYS_ADMIN"
  [ -c /dev/fuse ] && DEVICES+=" --device /dev/fuse"
}

prepare_docker_shared_memory_size() {
  # https://github.com/SeleniumHQ/docker-selenium/issues/388
  EXTRA+=" --shm-size=2g"
}

prepare_docker_userdata_volumes() {
  # User media folders
  MOUNTS+=" --mount type=bind,source=$HOME/Documents,target=/home/$USER_NAME/Documents"
  MOUNTS+=" --mount type=bind,source=$HOME/Downloads,target=/home/$USER_NAME/Downloads"
  MOUNTS+=" --mount type=bind,source=$HOME/Music,target=/home/$USER_NAME/Music"
  MOUNTS+=" --mount type=bind,source=$HOME/Pictures,target=/home/$USER_NAME/Pictures"
  MOUNTS+=" --mount type=bind,source=$HOME/Videos,target=/home/$USER_NAME/Videos"
  # ssh config
  [ -d ${HOME}/.ssh ] || mkdir -p ${HOME}/.ssh
  MOUNTS+=" --mount type=bind,source=${HOME}/.ssh,target=/home/${USER_NAME}/.ssh"
  # Maven config
  [ -d ${HOME}/.m2 ] || mkdir -p ${HOME}/.m2
  MOUNTS+=" --mount type=bind,source=${HOME}/.m2,target=/home/${USER_NAME}/.m2"
  # Git config
  [ -f ${HOME}/.gitconfig ] || touch ${HOME}/.gitconfig
  MOUNTS+=" --mount type=bind,source=${HOME}/.gitconfig,target=/home/${USER_NAME}/.gitconfig"
  # Thunderbird config
  [ -d ${HOME}/.thunderbird ] || mkdir -p ${HOME}/.thunderbird
  MOUNTS+=" --mount type=bind,source=${HOME}/.thunderbird,target=/home/${USER_NAME}/.thunderbird"
  # Chrome config
  [ -d ${HOME}/.config/google-chrome ] || mkdir -p ${HOME}/.config/google-chrome
  MOUNTS+=" --mount type=bind,source=${HOME}/.config/google-chrome,target=/home/${USER_NAME}/.config/google-chrome"
  # Filezilla config
  [ -d ${HOME}/.config/filezilla ] || mkdir -p ${HOME}/.config/filezilla
  MOUNTS+=" --mount type=bind,source=${HOME}/.config/filezilla,target=/home/${USER_NAME}/.config/filezilla"
  # VLC config
  [ -d ${HOME}/.config/vlc ] || mkdir -p ${HOME}/.config/vlc
  MOUNTS+=" --mount type=bind,source=${HOME}/.config/vlc,target=/home/${USER_NAME}/.config/vlc"
  # Remmina config
  [ -d ${HOME}/.config/remmina ] || mkdir -p ${HOME}/.config/remmina
  MOUNTS+=" --mount type=bind,source=${HOME}/.config/remmina,target=/home/${USER_NAME}/.config/remmina"
  # Calibre library
  [ -d ${HOME}/.config/calibre ] || mkdir -p ${HOME}/.config/calibre
  [ -f "${HOME}/Calibre Library" ] || mkdir -p "${HOME}/Calibre Library"
  MOUNTS+=" --mount type=bind,source=${HOME}/.config/calibre,target=/home/${USER_NAME}/.config/calibre"
  MOUNTS+=" --mount type=bind,source=${HOME}/Calibre\ Library,target=/home/${USER_NAME}/Calibre\ Library"
  # Microsoft Teams
  [ -d ${HOME}/.config/Microsoft ] || mkdir -p ${HOME}/.config/Microsoft
  MOUNTS+=" --mount type=bind,source=${HOME}/.config/Microsoft,target=/home/${USER_NAME}/.config/Microsoft"
  # Zoom
  [ -d ${HOME}/.zoom ] || mkdir -p ${HOME}/.zoom
  MOUNTS+=" --mount type=bind,source=${HOME}/.zoom,target=/home/${USER_NAME}/.zoom"
  # Slack
  [ -d ${HOME}/.config/Slack ] || mkdir -p ${HOME}/.config/Slack
  MOUNTS+=" --mount type=bind,source=${HOME}/.config/Slack,target=/home/${USER_NAME}/.config/Slack"
  # Shared working directory
  if [ -d /work ]; then
    MOUNTS+=" --mount type=bind,source=/work,target=/work"
  fi
}

prepare_docker_timezone
prepare_docker_user_and_group
prepare_docker_from_docker
prepare_docker_dbus_host_sharing
prepare_docker_xdg_runtime_dir_host_sharing
prepare_docker_sound_host_sharing
prepare_docker_webcam_host_sharing
prepare_docker_gpu_host_sharing
prepare_docker_printer_host_sharing
prepare_docker_ipc_host_sharing
prepare_docker_x11_host_sharing
prepare_docker_hostname_host_sharing
prepare_docker_nvidia_drivers_install
prepare_docker_fuse_sharing
prepare_docker_shared_memory_size
prepare_docker_userdata_volumes

bash -c "docker run --rm -it \
  --name ubuntu-tini-desktop \
  ${SECURITY} \
  ${CAPABILITIES} \
  ${ENV_VARS} \
  ${DEVICES} \
  ${MOUNTS} \
  ${EXTRA} \
  ${RUNNER} \
  ${RUNNER_GROUPS} \
  rubensa/ubuntu-tini-desktop"
```

*NOTE*: Mounting /var/run/docker.sock allows host docker usage inside the container (docker-from-docker).

This way, the internal user UID an group GID are changed to the current host user:group launching the container and the existing files under his internal HOME directory that where owned by user and group are also updated to belong to the new UID:GID.

Functions prepare_docker_dbus_host_sharing, prepare_docker_xdg_runtime_dir_host_sharing, prepare_docker_sound_host_sharing, prepare_docker_webcam_host_sharing, prepare_docker_gpu_host_sharing, prepare_docker_printer_host_sharing, prepare_docker_ipc_host_sharing, prepare_docker_x11_host_sharing, prepare_docker_hostname_host_sharing, prepare_docker_fuse_sharing and prepare_docker_shared_memory_size allows sharing your host resources with the running container as GUI apps can interact with your host system as they where installed in the host.

Function prepare_docker_nvidia_drivers_install allows the nvidia drivers host version to be installed on container.

Function prepare_docker_in_docker allows use docker host daemon inside container (Docker in Docker).

Function prepare_docker_userdata_volumes allows keep application config in user host HOME directory.

## Connect

You can connect to the running container like this:

```
#!/usr/bin/env bash

docker exec -it \
  ubuntu-tini-desktop \
  bash -l
```

This creates a bash shell run by the internal user.

Once connected...

You can run any installed application:

```
calibre
google-chrome-stable
deluge
draw.io
filezilla
gimp
inkscape
krita
libreoffice
meld
pencil
remmina
teams
thunderbird
vlc
zoom
```

## Stop

You can stop the running container like this:

```
#!/usr/bin/env bash

docker stop \
  ubuntu-tini-desktop
```

## Start

If you run the container without --rm you can start it again like this:

```
#!/usr/bin/env bash

# IMPORTANT! You MUST run this command before starting the container to update the link
if [ -f "${XAUTHORITY}" ] && [ "${XAUTHORITY}" != "${HOME}/.Xauthority" ]; then ln -sf "${XAUTHORITY}" "${HOME}/.Xauthority"; fi;

docker start \
  ubuntu-tini-desktop
```

## Remove

If you run the container without --rm you can remove once stopped like this:

```
#!/usr/bin/env bash

docker rm \
  ubuntu-tini-desktop
```
