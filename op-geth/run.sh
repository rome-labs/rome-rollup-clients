#! /bin/bash
set -e

# ********************
# Log Functions
# ********************

# Define color codes
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
RESET="\e[0m"

# Function to log general messages
log() {
    echo -e "${GREEN}$1${RESET}"
}

# Function to log error messages
error() {
    echo -e "${RED}Error: $1${RESET}" >&2
}

# Function to log warning messages
warn() {
    echo -e "${YELLOW}Warning: $1${RESET}"
}

# ********************
# Environment Check Functions
# ********************

check_commands() {
    for cmd in "$@"; do
        if ! command -v "$cmd" &> /dev/null; then
            error "Command not found: $cmd"
            error "Please install $cmd to continue."
            exit 1
        fi
    done
}

# ********************
# Check if required commands are available
# ********************

commands=("mkdir" "rm" "read" "echo" "cut" "awk" "sed" "grep")
check_commands "${commands[@]}"

# ********************
# Setting
# ********************

# Initial values with defaults
# Assign default values if not present in the environment
GETH_NAME="${GETH_NAME:-op-geth}"
CHAIN_ID="${CHAIN_ID}"
GASLIMIT="${GASLIMIT:-0x80000000}"
HTTP_PORT="${HTTP_PORT:-8545}"
ENGINE_PORT="${ENGINE_PORT:-8551}"
DISCOVERY_PORT="${DISCOVERY_PORT:-30303}"
GETH_BINARY="${GETH_BINARY:-/usr/local/bin/geth}"
GETH_BASE_DATA_DIR="${GETH_BASE_DATA_DIR:-$HOME/.ethereum}"
ACCOUNT_PASSWORD="${ACCOUNT_PASSWORD:-qwerty}"

# Check if GETH_BINARY exists; if not, use "geth"
if [ ! -f "$GETH_BINARY" ]; then
    warn "$GETH_BINARY not found. Using default 'geth' command."
    GETH_BINARY=$(which geth)
fi

# ********************
# Check if Geth binary exists
# ********************

if [ ! -x "$GETH_BINARY" ]; then
    error "Geth binary not found at: $GETH_BINARY"
    error "Please check the path to Geth binary."
    exit 1
fi

# Check if GETH_BASE_DATA_DIR exists; if not, create it
if [ ! -d "$GETH_BASE_DATA_DIR" ]; then
    warn "$GETH_BASE_DATA_DIR does not exist. Creating it now..."
    mkdir -p "$GETH_BASE_DATA_DIR"
fi

# ********************
# Derived Variables
# ********************

WS_PORT=$((HTTP_PORT + 1))
GETH_DATA_DIR="${GETH_BASE_DATA_DIR}/${GETH_NAME}-data"
GENESIS_FILE_PATH="${GETH_DATA_DIR}/genesis.json"
JWT_PATH="${GETH_DATA_DIR}/jwtsecret"

# ********************
# echo all the variables
# ********************

log "Using GETH_NAME: $GETH_NAME"
log "Using CHAIN_ID: $CHAIN_ID"
log "Using GASLIMIT: $GASLIMIT"
log "Using HTTP_PORT: $HTTP_PORT"
log "Using ENGINE_PORT: $ENGINE_PORT"
log "Using DISCOVERY_PORT: $DISCOVERY_PORT"

log "Using GETH_BINARY: $GETH_BINARY"
log "Using GETH_BASE_DATA_DIR: $GETH_BASE_DATA_DIR"
log "Using GETH_DATA_DIR: $GETH_DATA_DIR"
log "Using GENESIS_FILE_PATH: $GENESIS_FILE_PATH"
log "Using JWT PATH: $JWT_PATH"

# ********************
# Setup
# ********************

log "Checking if Geth data directory exists at ${GETH_DATA_DIR}"

if [ ! -d "${GETH_DATA_DIR}" ]; then
    log "Setting up Geth data directory at ${GETH_DATA_DIR}"
    mkdir -p "${GETH_DATA_DIR}"
else
    log "Geth data directory already exists at ${GETH_DATA_DIR}"
fi

log "[Current] Genesis address set to: $GENESIS_ADDRESS"

# ********************
# Generate genesis file
# ********************

# check if the genesis file already exists

if [ ! -f "$GENESIS_FILE_PATH" ]; then
    warn "Genesis file does not exist. Creating..."
    # Use the correct variable substitution syntax in the heredoc
    cat <<EOL > "${GENESIS_FILE_PATH}"
{
  "config": {
    "chainId": $CHAIN_ID,
    "homesteadBlock": 0,
    "eip150Block": 0,
    "eip155Block": 0,
    "eip158Block": 0,
    "byzantiumBlock": 0,
    "constantinopleBlock": 0,
    "petersburgBlock": 0,
    "istanbulBlock": 0,
    "muirGlacierBlock": 0,
    "berlinBlock": 0,
    "londonBlock": 0,
    "arrowGlacierBlock": 0,
    "grayGlacierBlock": 0,
    "mergeNetsplitBlock": 0,
    "shanghaiTime": 0,
    "bedrockBlock": 0,
    "regolithTime": 0,
    "cancunTime": 0,
    "terminalTotalDifficulty": 0,
    "terminalTotalDifficultyPassed": true
  },
  "nonce": 0,
  "timestamp": "0x657e3cc8",
  "gasLimit": 9900000000,
  "difficulty": "0x0",
  "mixHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "coinbase": "${GENESIS_ADDRESS}",
  "alloc": {
    "${GENESIS_ADDRESS}": { "balance": "${GENESIS_BALANCE}" }
  },
  "number": 0,
  "gasUsed": "0x0",
  "baseFeePerGas": "0x0",
  "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000"
}
EOL
    log "Genesis file created at ${GENESIS_FILE_PATH}"
    # Display the content of the genesis file
    cat "${GENESIS_FILE_PATH}"

    log "Initializing Geth with the genesis file..."
    # Directly use the geth command with correct syntax
    $GETH_BINARY init --datadir ${GETH_DATA_DIR} ${GENESIS_FILE_PATH}
fi


# ********************
# Generate JWT secret
# ********************

if [ ! -f "$JWT_PATH" ]; then
    warn "JWT secret does not exist. Creating..."
    # Use the correct variable substitution syntax in the heredoc
    echo "${JWT_SECRET}" > "${JWT_PATH}"
    # openssl rand -hex 32 > "${JWT_PATH}"
    # Print the path to the JWT secret
    log "JWT secret created at ${JWT_PATH}"
    # Display the content of the JWT secret
    cat "${JWT_PATH}"
fi


# ********************
# Start Geth
# ********************

log "Starting Geth"

$GETH_BINARY --datadir "${GETH_DATA_DIR}" \
    --networkid $CHAIN_ID \
    --http \
    --http.corsdomain="*" \
    --http.vhosts="*" \
    --http.addr "0.0.0.0" \
    --http.port $HTTP_PORT \
    --http.api "web3,debug,eth,txpool,net,engine,personal" \
    --ws \
    --ws.addr "0.0.0.0" \
    --ws.port $WS_PORT \
    --ws.origins "*" \
    --ws.api "debug,eth,txpool,net,engine,web3,personal" \
    --nodiscover \
    --maxpeers=0 \
    --authrpc.addr "0.0.0.0" \
    --authrpc.port $ENGINE_PORT \
    --authrpc.vhosts "*" \
    --rpc.txfeecap=0 \
    --rpc.gascap=0 \
    --txpool.lifetime=10m \
    --authrpc.jwtsecret $JWT_PATH \
    --gcmode=archive \
    --port $DISCOVERY_PORT &

# ********************
# Start Nginx
# ********************

log "Starting nginx"
nginx -g 'daemon off;' &

log "Keeping the container alive"
tail -f /dev/null