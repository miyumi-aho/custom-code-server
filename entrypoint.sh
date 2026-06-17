#!/bin/bash
set -e

# Read the environment variables safely (since $EUID is a reserved bash variable)
TARGET_UID=$(printenv EUID 2>/dev/null || echo "0")
TARGET_GID=$(printenv EGID 2>/dev/null || echo "0")
TARGET_USER=${EUSER:-coder}
TARGET_GROUP=${EGROUP:-coder}
TARGET_HOME=${EHOME:-/home/coder}

# Update group ID if it doesn't match
CURRENT_GID=$(id -g $TARGET_USER)
if [ "$CURRENT_GID" != "$TARGET_GID" ]; then
    groupmod -o -g "$TARGET_GID" "$TARGET_GROUP"
fi

# Update user ID if it doesn't match
CURRENT_UID=$(id -u $TARGET_USER)
if [ "$CURRENT_UID" != "$TARGET_UID" ]; then
    usermod -o -u "$TARGET_UID" "$TARGET_USER"
fi

# Fix ownership of the home directory
chown -R "$TARGET_UID:$TARGET_GROUP" "$TARGET_HOME"

# Handle the AUTH environment variable
AUTH_MODE=${AUTH:-none}

# Execute the command as the target user, appending the --auth flag!
exec gosu "$TARGET_USER" "$@" --auth "$AUTH_MODE"

