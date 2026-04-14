#!/bin/bash
set -e

mkdir -p /tmp/.ivy2

CURRENT_USER=$(whoami 2>/dev/null || echo "unknown")
CURRENT_UID=$(id -u 2>/dev/null || echo "unknown")

if [ -z "$USER" ] || [ "$USER" = "unknown" ]; then
  if [ "$CURRENT_UID" = "1001" ]; then
    export USER="spark"
  else
    export USER="$CURRENT_USER"
  fi
fi

if [ -z "$HOME" ] || [ "$HOME" = "?" ] || [ "$HOME" = "/" ]; then
  if [ "$USER" = "spark" ]; then
    export HOME="/opt/bitnami/spark"
  else
    export HOME="/tmp"
  fi
fi

export HADOOP_USER_NAME="${HADOOP_USER_NAME:-$USER}"

echo "[baseline] Running minimal entrypoint"
echo "[baseline] USER=$USER HOME=$HOME HADOOP_USER_NAME=$HADOOP_USER_NAME whoami=$CURRENT_USER uid=$CURRENT_UID"

exec "$@"
