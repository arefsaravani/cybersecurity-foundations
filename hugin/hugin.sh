#!/usr/bin/env bash
echo "Hugin: Linux Security Auditor"

SHADOW_FILE="${SHADOW_FILE:-/etc/shadow}"

if [ "$(id -u)" -ne 0 ]; then
    echo "[SKIP] Run as root to read $SHADOW_FILE"
    exit 0
fi

if [ ! -f "$SHADOW_FILE" ] || [ ! -r "$SHADOW_FILE" ]; then
    echo "[SKIP] Cannot read $SHADOW_FILE (missing or unreadable)"
    exit 0
fi

empty_users=$(awk -F: '$2 == "" {print $1}' "$SHADOW_FILE")
awk_status=$?

if [ "$awk_status" -ne 0 ]; then
    echo "[SKIP] Failed to parse $SHADOW_FILE"
    exit 1
fi

if [ -n "$empty_users" ]; then
    echo "[FAIL] Users with empty password fields:"
    printf '%s\n' "$empty_users"
else
    echo "[PASS] No users with empty password fields found."
fi
