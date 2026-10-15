#!/usr/bin/env bash

SHADOW_FILE="${SHADOW_FILE:-/etc/shadow}"

check_empty_passwords() {
  local empty_users

  if [[ "$(id -u)" -ne 0 ]]; then
    echo "[SKIP] you have no privilege: run as root"
    return 2
  fi

  if [[ ! -f "$SHADOW_FILE" ]] || [[ ! -r "$SHADOW_FILE" ]]; then
    echo "[SKIP] cannot read $SHADOW_FILE"
    return 2
  fi

  if ! empty_users=$(awk -F: '$2 == "" {print $1}' "$SHADOW_FILE"); then
    echo "[SKIP] failed to parse $SHADOW_FILE"
    return 2
  fi

  if [[ -n "$empty_users" ]]; then
    echo "[FAIL] users with empty passwords:"
    printf '%s\n' "$empty_users"
    return 1
  fi

  echo "[PASS] no users with empty passwords found"
  return 0
}

main() {
  echo "hugin: Linux Security Auditor"
  check_empty_passwords
}

main "$@"
