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
  "alloc": {
    "0xff00000000000000000000000000000000000007": {"balance": "0x0", "code": "0x608060405234801561001057600080fd5b50610115806100206000396000f3fe6080604052348015600f57600080fd5b506004361060465760003560e01c80638ac00bdc14604b5780638bc4742e14606d578063d5683ff7146097578063fb2ca9b114606d575b600080fd5b606b60048036036040811015605f57600080fd5b508035906020013560d6565b005b606b60048036036040811015608157600080fd5b508035906020013567ffffffffffffffff1660d6565b606b6004803603608081101560ab57600080fd5b5080359067ffffffffffffffff602082013516906001600160a01b03604082013516906060013560da565b5050565b5050505056fea265627a7a723158203d1dcd53734556bc0033bd1c158e73388d12ad311c0754e34dee937a67fc9dc964736f6c63430005100032"},
    "0xff00000000000000000000000000000000000005": {"balance": "0x0", "code": "0x608060405234801561001057600080fd5b5060cf8061001f6000396000f3fe6080604052348015600f57600080fd5b5060043610603c5760003560e01c806366c1cf1e1460415780637292100c146072578063ae9f75e3146072575b600080fd5b607060048036036060811015605557600080fd5b506001600160a01b0381351690602081013590604001356095565b005b607060048036036060811015608657600080fd5b50803590602081013590604001355b50505056fea265627a7a72315820d57d45449cca1849982079910d2acea6f60d08c7b7489fed5b75dcec02807aea64736f6c63430005100032"},
    "0xff00000000000000000000000000000000000006": {"balance": "0x0", "code": "0x6080604052348015600f57600080fd5b5060918061001e6000396000f3fe6080604052348015600f57600080fd5b506004361060285760003560e01c80635b4fdca014602d575b600080fd5b605660048036036040811015604157600080fd5b506001600160a01b0381351690602001356058565b005b505056fea265627a7a723158204530648f860a77a5d13a99a7a2941c27e708ea78f309a34b7a11da4190020a3b64736f6c63430005100032"}
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