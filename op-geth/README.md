# Endpoint Documentation

## Available Endpoints

### 1. Geth Node Endpoint
- **Path:** `/`
- **Description:** Proxies all requests to the Geth node.
- **Method:** All HTTP methods.
- **Access:** Unrestricted.

### 2. WebSocket Endpoint
- **Path:** `/ws`
- **Description:** Proxies WebSocket connections to the Geth WebSocket port.
- **Method:** WebSocket protocol.
- **Access:** Unrestricted.

## Restricted Endpoints

### 1. Airdrop Endpoint
- **Path:** `/airdrop`
- **Description:** Proxies requests to the Express server's airdrop endpoint.
- **Method:** All HTTP methods.
- **Access:** Restricted to specific IP addresses (52.22.11.22, 127.0.0.1).

### 2. JWT Endpoint
- **Path:** `/jwt`
- **Description:** Proxies requests to the Express server's JWT endpoint.
- **Method:** All HTTP methods.
- **Access:** Restricted to specific IP addresses (52.22.11.22, 127.0.0.1).

### 3. Geth Engine Endpoint
- **Path:** `/engine`
- **Description:** Proxies requests to the Geth engine port.
- **Method:** All HTTP methods.
- **Access:** Restricted to specific IP addresses (52.22.11.22, 127.0.0.1).

## Notes
- All endpoints that use SSL are served over HTTPS on port 443.
- HTTP requests are automatically redirected to HTTPS.
- The `/airdrop`, `/jwt`, and `/engine` endpoints are restricted to requests from specific IP addresses for security purposes.

