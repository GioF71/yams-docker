#!/bin/bash

# error codes
# 9 Invalid parameter
# 10 Missing mandatory parameter

DEFAULT_UID=1000
DEFAULT_GID=1000

DEFAULT_RUNTIME_DIR=/data
runtime_dir=$DEFAULT_RUNTIME_DIR

if [ ! -w "$runtime_dir" ]; then
    echo "Runtime dir [$runtime_dir] is not writable, switching to /tmp ..."
    runtime_dir=/tmp
fi

echo "Creating config directory [$runtime_dir/.config/yams] ..."
mkdir -p $runtime_dir/.config/yams
echo "Creating state directory [$runtime_dir/.local/state/yams] ..."
mkdir -p $runtime_dir/.local/state/yams
echo "Finished creating directories."

#CMD_LINE="XDG_RUNTIME_DIR=$runtime_dir yams --keep-alive --no-daemon"
CMD_LINE="yams --keep-alive --no-daemon"
echo "CMD_LINE=[$CMD_LINE]"

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

if [[ -n "${API_KEY}" && -n "${API_SECRET}" ]]; then
    CMD_LINE="$CMD_LINE --api-key ${API_KEY} --api-secret ${API_SECRET}"
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

# add session file path?
use_custom_session_file=0
if [[ -n "${SESSION_FILE}" ]]; then
    echo "SESSION_FILE=[$SESSION_FILE]"
    if [ -f "$SESSION_FILE" ]; then
        echo "SESSION_FILE [$SESSION_FILE] exists"
        use_custom_session_file=1
        CMD_LINE="$CMD_LINE --session-file-path $SESSION_FILE"
    fi
fi

if [ $use_custom_session_file -eq 0 ]; then
    echo "Creating directory for session file [$runtime_dir/.config/yams] ..."
    mkdir -p $runtime_dir/.config/yams
    echo "Setting default session file to [$runtime_dir/.config/yams/.lastfm_session] ..."
    CMD_LINE="$CMD_LINE --session-file-path $runtime_dir/.config/yams/.lastfm_session"
fi

uid=$(id -u)
if [[ $uid -ne 0 ]]; then
    echo "This container must be run as root."
    exit 1
fi

echo "Running with uid=[$uid] ..."
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
    mkdir -p $runtime_dir
    echo "Setting ownership ..."
    chown -R yams-user:yams-group /app/log
    chown -R yams-user:yams-group $runtime_dir
    echo "Setting home directory ..."
    usermod --home $runtime_dir yams-user
    cat /etc/passwd | grep $USER_NAME
    if [ ! -f $runtime_dir/.config/yams/yams.yml ]; then
        echo "Configuration file not found, generating ..."
        exec su - $USER_NAME -c "XDG_RUNTIME_DIR=$runtime_dir yams --generate-config"        
    fi
    if [ -f $runtime_dir/.config/yams/yams.pid ]; then
        echo "Removing pid ..."
        rm $runtime_dir/.config/yams/yams.pid
        echo "Removed pid"
    fi
    echo "Executing [$CMD_LINE] with runtime_dir=[$runtime_dir] ..."
    exec su - $USER_NAME -c "XDG_RUNTIME_DIR=$runtime_dir $CMD_LINE"
else
    echo "This container must be run in user mode."
    exit 1
fi
