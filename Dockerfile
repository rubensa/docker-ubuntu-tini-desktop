# syntax=docker/dockerfile:1.4
FROM rubensa/ubuntu-tini-desktop
LABEL author="Ruben Suarez <rubensa@gmail.com>"

# $(id -un)
ARG NEW_USER_NAME=
# $(id -gn)
ARG NEW_GROUP_NAME=

# Use USER_NAME if no NEW_USER_NAME specified
ENV NEW_USER_NAME=${NEW_USER_NAME:-$USER_NAME}
# Use GROUP_NAME if no NEW_GROUP_NAME specified
ENV NEW_GROUP_NAME=${NEW_GROUP_NAME:-$GROUP_NAME}

# Tell docker that all future commands should be run as root
USER root

# Set root home directory
ENV HOME=/root

# Custom username
RUN <<EOT
if [ "${NEW_USER_NAME}" != "${USER_NAME}" ]; then
  usermod -l ${NEW_USER_NAME} -d /home/${NEW_USER_NAME} -m ${USER_NAME}
  # Add sudo support for new user
  # FIX: Filename under /etc/sudoers.d does not support periods.  Do it the hacky way...
  FILENAME="$( echo $NEW_USER_NAME | tr  '.' '_'  )"
  echo "${NEW_USER_NAME} ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/${FILENAME}
  chmod 0440 /etc/sudoers.d/${FILENAME}
  # Revome old user sudo support
  rm /etc/sudoers.d/${USER_NAME}
fi
EOT

# Custom groupname
RUN <<EOT
if [ "${NEW_GROUP_NAME}" != "${GROUP_NAME}" ]; then
  # groupmod -n ${NEW_GROUP_NAME} ${GROUP_NAME}
  # FIX: groupmod does not support spaces in group name.  Do it the hacky way...
  sed -i 's/^'"$GROUP_NAME"':/'"$NEW_GROUP_NAME"':/g' /etc/group
fi
#
# Update fixuid config
printf "user: ${NEW_USER_NAME}\ngroup: ${NEW_GROUP_NAME}\npaths:\n  - /home/${NEW_USER_NAME}" > /etc/fixuid/config.yml
EOT

ENV USER_NAME=${NEW_USER_NAME}
ENV GROUP_NAME=${NEW_GROUP_NAME}

# Tell docker that all future commands should be run as the non-root user
USER ${USER_NAME}

# Set user home directory (see: https://github.com/microsoft/vscode-remote-release/issues/852)
ENV HOME=/home/${USER_NAME}

# Set default working directory to user home directory
WORKDIR ${HOME}
