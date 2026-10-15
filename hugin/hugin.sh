#!/usr/bin/env bash

SHADOW_FILE="${SHADOW_FILE:-/etc/shadow}"

check_empty_passwords() {
  local empty_users

  if [[ "$(id -u)" -ne 0 ]]; then
    echo "[SKIP] Empty passwords: needs root (try: sudo ./hugin/hugin.sh)"
    return 2
  fi

  if [[ ! -f "$SHADOW_FILE" ]] || [[ ! -r "$SHADOW_FILE" ]]; then
    echo "[SKIP] Empty passwords: $SHADOW_FILE not found or not readable"
    return 2
  fi

  if ! empty_users=$(awk -F: '$2 == "" {print $1}' "$SHADOW_FILE"); then
    echo "[SKIP] Empty passwords: could not parse $SHADOW_FILE"
    return 2
  fi

  if [[ -n "$empty_users" ]]; then
    echo "[FAIL] Empty passwords: these accounts have no password:"
    printf '%s\n' "$empty_users"
    return 1
  fi

  echo "[PASS] Empty passwords: no accounts with an empty password"
  return 0
}

main() {
  echo "Hugin: Linux Security Auditor"
  check_empty_passwords
}

main "$@"
