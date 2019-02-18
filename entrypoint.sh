#!/usr/bin/env bash

# Add local user
# Either use LOCAL_UID and LOCAL_GID if passed in at runtime via
# -e LOCAL_UID="$(id -u)" -e LOCAL_GID="$(id -g)" or fallback
USER_NAME=builder
RUN_UID=${LOCAL_UID:-1000}
RUN_GID=${LOCAL_GID:-1000}

groupadd --non-unique --gid "$RUN_GID" "$USER_NAME"
useradd --non-unique --create-home --uid "$RUN_UID" --gid "$USER_NAME" --groups sudo "$USER_NAME"

echo "$USER_NAME ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/user-no-sudo-password

export HOME=/home/"$USER_NAME"

exec gosu "$USER_NAME" "$@"
