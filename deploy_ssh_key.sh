#!/bin/bash

# Ensure .ssh directory exists and has correct permissions
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# --- BEGIN GPG ENCRYPTED DATA ---
# Replace the content between 'EOF_GPG_DATA' markers
# with the content of your /tmp/ssh_keys_bundle.txt.asc file.
GPG_DATA=$(cat <<'EOF_GPG_DATA'
-----BEGIN PGP MESSAGE-----

jA0ECQMK718EzgiMMVT/0sDSAck6cDu9+Laz+ODNiyMT/KFuvyOEm0ZngV4u3Z3l
Lfc6a6ZxANPyv8IU0zsgI1z49VWG6RwqgA3nZS32yFllAVlBy2t+lRX8k7rH/sk3
et6GNM4Ay3Bouvc8dA7bEeKm0VHNeAstHtqntLz68UJtdhi7kB6ayOVGCK0Qcs5T
1kDOoaoC3byBFhCUXabS6EWutlKsPbeXCzKPpqTCjo0l06zAGSTO/rQPvsGVqnqp
CN/8Cn+RQFWA6rxQYfkLaTnVHKxjr8W09aRabq/0oR+H6598QdJvGA3JA6k3O/Xv
D/+a7h8cqTGD06OAgiCbBVnPOF10IXmmuHu4qlmpihybvdL/qtw2M3wx++qUNRWf
B+wDfJY3U3VLCjUghMdyuVHE8JFmhFVSV90C2yB4zFapPATcRjcn1hQz1vHaBArZ
RR+7UuaoEsFxsqe50v03LJg7fdZDuQ+YRjxYQ/3kTOH3UTmHvAki0hhu0yS5n1hK
4IrQSjTOuZqUGfH+7IOB9pTb9TE6YPjq7DSLquzGKeSQttdl
=FYA+
-----END PGP MESSAGE-----
EOF_GPG_DATA
)
# --- END GPG ENCRYPTED DATA ---

# Prompt for GPG passphrase
read -rsp "Enter GPG passphrase to decrypt SSH key: " GPG_PASSPHRASE
echo

# Decrypt the data
DECRYPTED_KEYS=$(echo "$GPG_DATA" | gpg --decrypt --quiet --batch --passphrase-fd 3 --pinentry-mode loopback 3<<<"$GPG_PASSPHRASE" 2>/dev/null)


if [ -z "$DECRYPTED_KEYS" ]; then
    echo "Decryption failed. Invalid passphrase or GPG error." >&2
    unset GPG_PASSPHRASE
    exit 1
fi
unset GPG_PASSPHRASE # Clear passphrase from memory

# Extract the public key.
# This regex matches common SSH public key formats.
PUBLIC_KEY=$(echo "$DECRYPTED_KEYS" | grep -E '^(ssh-rsa|ssh-dss|ssh-ed25519|ecdsa-sha2-nistp256|ecdsa-sha2-nistp384|ecdsa-sha2-nistp521) AAAA[0-9A-Za-z+/]+[=]{0,3}')

if [ -z "$PUBLIC_KEY" ]; then
    echo "Could not extract public key from decrypted data." >&2
    # For debugging, you could uncomment the following line:
    # echo "Decrypted data was:" >&2; echo "$DECRYPTED_KEYS" >&2
    unset DECRYPTED_KEYS
    exit 1
fi
unset DECRYPTED_KEYS # Clear decrypted keys from memory

# Ensure authorized_keys file exists and set correct permissions
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Check if the key already exists to avoid duplicates
if grep -Fxq "$PUBLIC_KEY" ~/.ssh/authorized_keys; then
    echo "Public key already exists in ~/.ssh/authorized_keys."
else
    echo "$PUBLIC_KEY" >> ~/.ssh/authorized_keys
    if [ $? -eq 0 ]; then
        echo "Public key successfully added to ~/.ssh/authorized_keys."
    else
        echo "Failed to add public key to ~/.ssh/authorized_keys." >&2
        unset PUBLIC_KEY
        exit 1
    fi
fi

unset PUBLIC_KEY # Clear public key from memory
echo "SSH key deployment script finished."
