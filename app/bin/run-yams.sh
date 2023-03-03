#!/bin/bash

# error codes
# 9 Invalid parameter
# 10 Missing mandatory parameter

DEFAULT_UID=1000
DEFAULT_GID=1000

CMD_LINE="yams --keep-alive --no-daemon"

if [[ -n "${MPD_HOST}" ]]; then
    CMD_LINE="$CMD_LINE -m $MPD_HOST"
fi

if [[ -n "${MPD_PORT}" ]]; then
    if ! [[ $MPD_PORT =~ $number_re ]]; then
        echo "Invalid parameter MPD_PORT [$MPD_PORT] must be a number"
        exit 9
    fi
    CMD_LINE="$CMD_LINE -p $MPD_PORT"
fi

echo "CMD_LINE=[$CMD_LINE]"

number_re="^[0-9]+$"
if [[ -n "$STARTUP_DELAY_SEC" ]]; then
    if ! [[ $STARTUP_DELAY_SEC =~ $number_re ]]; then
        echo "Invalid parameter STARTUP_DELAY_SEC"
        exit 9
    fi
    if [[ $STARTUP_DELAY_SEC -gt 0 ]]; then
        echo "About to sleep for $STARTUP_DELAY_SEC second(s)"
        sleep $STARTUP_DELAY_SEC
        echo "Ready to start."
    fi
fi

# Create user and group
if [[ -n "{${PUID}" || -z "${USER_MODE}" || "${USER_MODE^^}" == "YES" ]]; then
    echo "User mode enabled"
    if [ -z "${PUID}" ]; then
        PUID=$DEFAULT_UID;
        echo "Setting default value for PUID: ["$PUID"]"
    fi
    if [ -z "${PGID}" ]; then
        PGID=$DEFAULT_GID;
        echo "Setting default value for PGID: ["$PGID"]"
    fi
    USER_NAME=yams-user
    GROUP_NAME=yams-group
    ### create group
    if [ ! $(getent group $GROUP_NAME) ]; then
        echo "group $GROUP_NAME does not exist, creating..."
        groupadd -g $PGID $GROUP_NAME
    else
        echo "group $GROUP_NAME already exists."
    fi
    ### create user
    if [ ! $(getent passwd $USER_NAME) ]; then
        echo "user $USER_NAME does not exist, creating..."
        useradd --no-create-home -g $PGID -u $PUID -s /bin/bash $USER_NAME
        id $USER_NAME
        echo "user $USER_NAME created."
    else
        echo "user $USER_NAME already exists."
    fi
    echo "Created $USER_NAME (group: $GROUP_NAME)"
    cat /etc/passwd|grep $USER_NAME
    echo "Creating home directory ..."
    mkdir -p /data
    echo "Setting ownership ..."
    chown -R yams-user:yams-group /app/log
    chown -R yams-user:yams-group /data
    echo "Setting home directory ..."
    usermod --home /data yams-user
    cat /etc/passwd|grep $USER_NAME
    # this should not be needed
    CMD_LINE="$CMD_LINE --session-file-path /data/.config/yams/.lastfm_session"
    echo "Executing ..."
    su - $USER_NAME -c "$CMD_LINE"
else
    eval "$CMD_LINE"
fi
