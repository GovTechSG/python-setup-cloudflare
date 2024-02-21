#!/usr/bin/env bash

if ! /usr/bin/env bash -c "$(curl -fsSL https://raw.githubusercontent.com/GovTechSG/python-setup-cloudflare/master/install-certificates-for-python-osx.sh)"; then
    exit 1
fi

read -p "Install aider-chat Now? (y/n) [default: n]: " response
response=$(echo "$response" | tr '[:upper:]' '[:lower:]')

if [[ "$response" != "y" && "$response" != "yes" ]]; then
    echo "Exiting." >&2
    exit 1
fi

echo "[aider-install] Starting"

if ! python3 -m pip install -q --upgrade --user aider-chat; then
    echo "[aider-install] Failed to install aider-chat. Please check the error message above for more details." >&2
    exit 1
fi

echo "[aider-install] Completed successfully. Remember to setup your Azure/OpenAI Credentials!"
