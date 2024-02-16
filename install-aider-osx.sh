#!/usr/bin/env bash

CLOUDFLARE_CA_URL="https://developers.cloudflare.com/cloudflare-one/static/Cloudflare_CA.pem"

cat << 'EOF'
=============================================================================
        _     _                         _                                    
   __ _(_) __| | ___ _ __      ___  ___| |_ _   _ _ __         __ _  ___ ___ 
  / _` | |/ _` |/ _ \ '__|____/ __|/ _ \ __| | | | '_ \ _____ / _` |/ __/ __|
 | (_| | | (_| |  __/ | |_____\__ \  __/ |_| |_| | |_) |_____| (_| | (_| (__ 
  \__,_|_|\__,_|\___|_|       |___/\___|\__|\__,_| .__/       \__, |\___\___|
                                                 |_|          |___/          
=============================================================================
EOF

cat << EOF
This tool allows you to configure your macOS environment with Cloudflare
to make API requests to Azure GCC. It will:
$(echo -e "\033[31m")
1. Configure your Python Environment to trust the *Cloudflare Root CA*.
2. Help you setup the necessary environment variables to use the Azure OpenAI
   from within GCC.
$(echo -e "\033[0m")
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

read -p "Do you agree? (y/n) [default: n]: " response
response=$(echo "$response" | tr '[:upper:]' '[:lower:]')

if [[ "$response" != "y" && "$response" != "yes" ]]; then
    echo "Exiting. You did not agree." >&2
    exit 1
fi

read -p "Please turn off Cloudflare now. Proceed with Installation? (y/n) [default: n]: " response
response=$(echo "$response" | tr '[:upper:]' '[:lower:]')

if [[ "$response" != "y" && "$response" != "yes" ]]; then
    echo "Exiting. You did not agree." >&2
    exit 1
fi


# ============= END OF DISCLAIMERS ==============

if [[ -n "$VIRTUAL_ENV" ]]; then
    echo "Please install install and configure `aider` outside of your virtualenv."  >&2
    echo "Start a new shell in your Terminal/iTerm App" >&2
    exit 1
fi

# ============= END OF CHECKS ==============

echo "[aider-install] Starting"

if ! pip install -q --upgrade --user certifi aider-chat; then
    echo "[aider-install] Failed to install aider-chat. Please check the error message above for more details." >&2
    exit 1
fi

echo "[aider-install] Completed successfully"

# ============= END OF AIDER INSTALLATION ==============

PEM_PATH=$(python -m certifi)

echo "[Cloudflare] Downloading Root CA"

if ! curl --fail -s -o /tmp/Cloudflare_CA.pem $CLOUDFLARE_CA_URL > /dev/null; then
    echo "[Cloudflare] Downloading Root CA failed" >&2
    exit 1
fi

echo -e "# Cloudflare Root CA\n$(cat input)" > input


CLOUDFLARE_CA_SIGNATURE=$(sed -n '2p' /tmp/Cloudflare_CA.pem)

if ! grep -q "$CLOUDFLARE_CA_SIGNATURE" "$PEM_PATH"; then
    echo "[Cloudflare] Adding Cloudflare Root CA to $PEM_PATH"
    if ! echo | cat - /tmp/Cloudflare_CA.pem >> "$PEM_PATH"; then
        echo "Error: Failed to append /tmp/Cloudflare_CA.pem to $PEM_PATH" >&2
        exit 1
    fi
else
    echo "[Cloudflare] No further configuration needed! CA already in $PEM_PATH"
fi

# https://developers.cloudflare.com/cloudflare-one/connections/connect-devices/warp/user-side-certificates/install-cloudflare-cert/#python-on-mac-and-linux

CA_ENV_VARS=("CERT_PATH" "SSL_CERT_FILE" "REQUESTS_CA_BUNDLE")
CA_ENV_EXPORTS="export CERT_PATH=${CERT_PATH}
export SSL_CERT_FILE=${CERT_PATH}
export REQUESTS_CA_BUNDLE=${CERT_PATH}
"

CONFIG_FILES=(".zshrc" ".bash_profile" ".bashrc" ".profile")

append_ca_env_vars() {
    local config_path=$1
    local skip_var=0

    for var_name in "${CA_ENV_VARS[@]}"; do
        if grep -q "^export ${var_name}=" "$config_path"; then
            echo "[Cloudflare] Variable ${var_name} already defined in ${config_path}, skipping."
            skip_var=1
            break
        fi
    done

    if [ $skip_var -eq 0 ]; then
        echo "[Cloudflare] Adding environment variables to ${config_path}"
        echo "$CA_ENV_EXPORTS" >> "$config_path"
    fi
}

for file in "${CONFIG_FILES[@]}"; do
    CONFIG_PATH="${HOME}/${file}"
    if [ -f "${CONFIG_PATH}" ]; then
        append_ca_env_vars "${CONFIG_PATH}"
    else
        echo "[Cloudflare] ${CONFIG_PATH} does not exist, skipping."
    fi
done

# ============= END OF CLOUDFLARE COMPATIBILITY ==============

read -p "Do you want to configure Azure OpenAI? (y/n) [default: n]: " response
response=$(echo "$response" | tr '[:upper:]' '[:lower:]')

if [[ "$response" != "y" && "$response" != "yes" ]]; then
    echo "Exiting. You did not agree." >&2
    exit 1
fi

