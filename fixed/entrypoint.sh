#!/bin/bash
set -e

export HADOOP_USER_NAME="spark"
CURRENT_USER=$(whoami 2>/dev/null || echo "unknown")
CURRENT_UID=$(id -u 2>/dev/null || echo "unknown")

if [ "$CURRENT_USER" = "unknown" ] && [ "$CURRENT_UID" != "unknown" ]; then
  CURRENT_USER="uid${CURRENT_UID}"
fi

if [ -z "$USER" ] || [ "$USER" = "unknown" ]; then
  if [ "$CURRENT_UID" = "0" ]; then
    export USER="root"
  elif [ "$CURRENT_UID" = "1001" ]; then
    export USER="spark"
  else
    export USER="$CURRENT_USER"
  fi
fi

RUNTIME_ROOT="${SIMPLIFIED_RUNTIME_ROOT:-/tmp/simplified-pyspark-${CURRENT_UID}}"
export SIMPLIFIED_RUNTIME_ROOT="$RUNTIME_ROOT"
export SIMPLIFIED_IVY_DIR="${SIMPLIFIED_IVY_DIR:-/tmp/.ivy2}"
export SIMPLIFIED_WAREHOUSE_DIR="${SIMPLIFIED_WAREHOUSE_DIR:-$RUNTIME_ROOT/spark-warehouse}"
export SIMPLIFIED_LOCAL_DIR="${SIMPLIFIED_LOCAL_DIR:-$RUNTIME_ROOT/spark-local}"
export SIMPLIFIED_WORKDIR="${SIMPLIFIED_WORKDIR:-$RUNTIME_ROOT/workdir}"

if [ -z "$HOME" ] || [ "$HOME" = "?" ] || [ "$HOME" = "/" ]; then
  export HOME="$RUNTIME_ROOT/home"
fi

mkdir -p \
  "$SIMPLIFIED_IVY_DIR" \
  "$SIMPLIFIED_WAREHOUSE_DIR" \
  "$SIMPLIFIED_LOCAL_DIR" \
  "$SIMPLIFIED_WORKDIR" \
  "$HOME"

if [ "$CURRENT_UID" != "0" ] && [ "$CURRENT_UID" != "1001" ] && [ -n "$USER" ] && [ "$USER" != "unknown" ]; then
  NSS_PASSWD_FILE="/tmp/nss_passwd_runtime_${CURRENT_UID}"
  NSS_GROUP_FILE="/tmp/nss_group_runtime_${CURRENT_UID}"

  cp /opt/bitnami/spark/tmp/nss_passwd "$NSS_PASSWD_FILE" 2>/dev/null || true
  cp /opt/bitnami/spark/tmp/nss_group "$NSS_GROUP_FILE" 2>/dev/null || true

  if ! grep -q ":x:$CURRENT_UID:" "$NSS_PASSWD_FILE" 2>/dev/null; then
    echo "$USER:x:$CURRENT_UID:$CURRENT_UID:Runtime User:$HOME:/bin/bash" >> "$NSS_PASSWD_FILE"
  fi

  if ! grep -q "^$USER:" "$NSS_GROUP_FILE" 2>/dev/null; then
    echo "$USER:x:$CURRENT_UID:" >> "$NSS_GROUP_FILE"
  fi

  export NSS_WRAPPER_PASSWD="$NSS_PASSWD_FILE"
  export NSS_WRAPPER_GROUP="$NSS_GROUP_FILE"
fi

export LOGNAME="$USER"
export USERNAME="$USER"
export HADOOP_HOME="/tmp"
export HADOOP_CONF_DIR="/tmp"
export SPARK_LOCAL_DIRS="$SIMPLIFIED_LOCAL_DIR"

echo "[fixed] HADOOP_USER_NAME=$HADOOP_USER_NAME"
echo "[fixed] USER=$USER CURRENT_USER=$CURRENT_USER CURRENT_UID=$CURRENT_UID"
echo "[fixed] HOME=$HOME"
echo "[fixed] SIMPLIFIED_RUNTIME_ROOT=$SIMPLIFIED_RUNTIME_ROOT"
echo "[fixed] SIMPLIFIED_IVY_DIR=$SIMPLIFIED_IVY_DIR"
echo "[fixed] SIMPLIFIED_LOCAL_DIR=$SIMPLIFIED_LOCAL_DIR"
echo "[fixed] SIMPLIFIED_WAREHOUSE_DIR=$SIMPLIFIED_WAREHOUSE_DIR"
echo "[fixed] SIMPLIFIED_WORKDIR=$SIMPLIFIED_WORKDIR"
echo "[fixed] NSS_WRAPPER_PASSWD=${NSS_WRAPPER_PASSWD:-unset}"
echo "[fixed] NSS_WRAPPER_GROUP=${NSS_WRAPPER_GROUP:-unset}"

cd "$SIMPLIFIED_WORKDIR"

exec "$@"
