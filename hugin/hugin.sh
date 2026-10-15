#!/usr/bin/env bash

SHADOW_FILE="${SHADOW_FILE:-/etc/shadow}"
PASSWD_FILE="${PASSWD_FILE:-/etc/passwd}"

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

check_uid_zero() {
  local uid_zero_users

  if [[ ! -f "$PASSWD_FILE" ]] || [[ ! -r "$PASSWD_FILE" ]]; then
    echo "[SKIP] UID Zero: $PASSWD_FILE not found or not readable"
    return 2
  fi

  if ! uid_zero_users=$(awk -F: '$3 == 0 && $1 != "root" {print $1}' "$PASSWD_FILE"); then
    echo "[SKIP] UID Zero: could not parse $PASSWD_FILE"
    return 2
  fi

  if [[ -n "$uid_zero_users" ]]; then
    echo "[FAIL] UID Zero: these accounts have 0 UID"
    printf '%s\n' "$uid_zero_users"
    return 1
  fi

  echo "[PASS] UID Zero: no accounts with 0 UID"
  return 0
}

main() {
  echo "Hugin: Linux Security Auditor"
  check_empty_passwords
  check_uid_zero
}

main "$@"
