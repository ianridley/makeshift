# SPDX-License-Identifier: LicenseRef-Procept
# SPDX-FileCopyrightText: Copyright © 2023 Procept Pty Ltd. All rights reserved.
#
# Build container for makeshift. Supports building deb packages exclusively.
#
FROM debian:bullseye

ARG DEBIAN_FRONTEND="noninteractive"

RUN apt-get -y update && apt-get -y install \
	build-essential \
	devscripts \
	git \
	git-lfs \
	sudo

# Bootstrap Makeshift
COPY . /tmp/makeshift
RUN cd /tmp/makeshift && sh install.sh
RUN rm -rf /tmp/makeshift

# setup a developer as the user
ARG USER_NAME=developer
ARG USER_GROUP=${USER_NAME}
ARG USER_HOME=/home/${USER_NAME}
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

RUN groupadd -g ${USER_GID} ${USER_GROUP}
RUN useradd -rm -d ${USER_HOME} -u ${USER_UID} -g ${USER_GID} -s /bin/bash -G sudo ${USER_NAME}
# add to nopassword
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER ${USER_NAME}
