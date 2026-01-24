#!/bin/bash
# ------------------------------------------------------------------
# Script Name: immich-fix-permissions.sh
# Description: Fixes file permissions on the external USB SSD for Immich.
#              Resolves ENOENT and EACCES errors by creating required
#              directories and setting ownership to Docker user (1000).
# ------------------------------------------------------------------

BASE_DIR="/mnt/external_drive/immich"

echo "--- 1. Creating Directory Structure ---"
# Creating subdirectories if they don't exist
mkdir -p "$BASE_DIR/library"
mkdir -p "$BASE_DIR/upload"
mkdir -p "$BASE_DIR/thumbs"
mkdir -p "$BASE_DIR/profile"
mkdir -p "$BASE_DIR/encoded-video"
mkdir -p "$BASE_DIR/backups"

echo "--- 2. Creating 'Magic Files' (Docker Check Bypass) ---"
# Touching .immich files to ensure Docker sees the volume mount correctly
touch "$BASE_DIR/library/.immich"
touch "$BASE_DIR/upload/.immich"
touch "$BASE_DIR/thumbs/.immich"
touch "$BASE_DIR/profile/.immich"
touch "$BASE_DIR/encoded-video/.immich"
touch "$BASE_DIR/backups/.immich"

echo "--- 3. Applying Permissions (User 1000) ---"
# Setting owner to 1000 (standard Docker user) and permissions to 777
chown -R 1000:1000 "$BASE_DIR"
chmod -R 777 "$BASE_DIR"

echo "--- Fix Complete! Restart your Immich container if needed. ---"