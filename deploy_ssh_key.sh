#!/bin/bash
# Optimized SSH Key Management Script

# --- Script Configuration and Error Handling ---
set -euo pipefail

# Ensure .ssh directory exists and has correct permissions
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

# --- BEGIN GPG ENCRYPTED DATA ---
GPG_DATA=$(cat <<'EOF_GPG_DATA'
-----BEGIN PGP MESSAGE-----

jA0ECQMKKTuI+e+kzlr/0sCSAXfSCoL2Alj02g2YBiarcn5cMvb8kOYuHbSs8OtF
c/zUkc80/0sXPqNCdfIWpnE5E/07iC/xmmgljZzhLSs3e59fLbXvMsnQtXHB4C2+
bqBYdI1H35NIBxHd48lx4adl0CmtBxyOcTHuedUtyDY3utcEgzN+pUZRbxbCDoey
l1ZKKdy4Z+v1dBRbtvbI4mr6jAbVfcuch3jji+ai/hOjA5s+xYQFrUPCdNRo8/Mw
4tkEctdQGoH66GHK8Sa5X7mVD5ohXi+Ryatbzu7S+pFLB/BqSPO41qU73Cgnkhs+
lTfv7r8cDzO9iZwK7DR3ZjcD0j6Qu7ccjHtf/Is36gP30RRq3FILqBpDbYirK2vj
pHhknO19lBHg5+ie787w2HFzorFSY7QyLw0MJdmNe2o89P7TEcfovDqDiCpC9VA/
pXKVbOIlrC8q/QDogkWS3DtpJiA=
=HmMG
-----END PGP MESSAGE-----
---SSH_KEY_BUNDLE_DELIMITER---
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO1QxSYZTQMfa1TJ2JVic/lUNSGcmkO/KgKkzicYt+Ag edenz223@outlook.com
EOF_GPG_DATA
)
# --- END GPG ENCRYPTED DATA ---

# Parse command line options
DECRYPT_PRIVATE_KEY=false
while getopts "p" opt; do
  case $opt in
    p) DECRYPT_PRIVATE_KEY=true ;;
    *) echo "Error: Invalid option: -$OPTARG" >&2; exit 1 ;;
  esac
done
shift $((OPTIND-1))

# Split GPG_DATA
ENCRYPTED_PRIVATE_KEY_BLOCK=$(echo "$GPG_DATA" | sed -n '/---SSH_KEY_BUNDLE_DELIMITER---/q;p')
PLAIN_PUBLIC_KEY_BLOCK=$(echo "$GPG_DATA" | sed '1,/---SSH_KEY_BUNDLE_DELIMITER---/d')

# Handle private key decryption if -p option is present
if [ "$DECRYPT_PRIVATE_KEY" = true ]; then
    printf "Enter GPG passphrase to decrypt private key: " >/dev/tty
    read -r -s GPG_PASSPHRASE </dev/tty
    echo >/dev/tty

    set +e
    DECRYPTED_PRIVATE_KEY=$(echo "$ENCRYPTED_PRIVATE_KEY_BLOCK" | \
        gpg --decrypt --quiet --batch --passphrase-fd 3 --pinentry-mode loopback 3<<<"$GPG_PASSPHRASE" 2>/dev/null)
    GPG_EXIT_STATUS=$?
    set -e

    unset GPG_PASSPHRASE

    if [ $GPG_EXIT_STATUS -ne 0 ] || [ -z "$DECRYPTED_PRIVATE_KEY" ]; then
        echo "Error: Private key decryption failed. Wrong passphrase or corrupted data." >&2
        exit 1
    fi

    PRIVATE_KEY_FILENAME="id_ed25519"
    echo "$DECRYPTED_PRIVATE_KEY" | grep -q "BEGIN RSA PRIVATE KEY" && PRIVATE_KEY_FILENAME="id_rsa"
    PRIVATE_KEY_PATH="$HOME/.ssh/$PRIVATE_KEY_FILENAME"

    if [ -f "$PRIVATE_KEY_PATH" ]; then
        printf "Warning: '%s' exists. Overwrite? (y/N): " "$PRIVATE_KEY_PATH" >/dev/tty
        read -r -n 1 -s CONFIRM </dev/tty
        echo >/dev/tty
        [[ ! "$CONFIRM" =~ ^[Yy]$ ]] && echo "Cancelled." >&2 && exit 0
    fi

    echo "$DECRYPTED_PRIVATE_KEY" > "$PRIVATE_KEY_PATH"
    chmod 600 "$PRIVATE_KEY_PATH"
    unset DECRYPTED_PRIVATE_KEY
    echo "Private key written to $PRIVATE_KEY_PATH."
fi

# Process public key
if [ -n "$PLAIN_PUBLIC_KEY_BLOCK" ]; then
    PUBLIC_KEY=$(echo "$PLAIN_PUBLIC_KEY_BLOCK" | \
        grep -E '^(ssh-rsa|ssh-dss|ssh-ed25519|ecdsa-sha2-nistp.*) AAAA[0-9A-Za-z+/]+[=]{0,3}(\s+\S+)?$')

    if [ -z "$PUBLIC_KEY" ]; then
        echo "Error: Could not extract a valid public key." >&2
        exit 1
    fi

    touch "$HOME/.ssh/authorized_keys"
    chmod 600 "$HOME/.ssh/authorized_keys"

    if grep -Fxq "$PUBLIC_KEY" "$HOME/.ssh/authorized_keys"; then
        echo "Public key already exists."
    else
        echo "$PUBLIC_KEY" >> "$HOME/.ssh/authorized_keys"
        echo "Public key added."
    fi
    unset PUBLIC_KEY
else
    echo "Error: No public key block found." >&2
    exit 1
fi

echo "Done."

