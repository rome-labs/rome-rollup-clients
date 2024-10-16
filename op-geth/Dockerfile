FROM alpine AS base

WORKDIR /app

ARG GETH_BRANCH="older-optimism"
ENV GOARCH="amd64"

RUN apk add --no-cache git make gcc musl-dev linux-headers go

COPY ../../op-geth /app/op-geth
RUN cd op-geth &&  make geth

FROM nginx:alpine AS run

WORKDIR /app

ENV GETH_NAME="op-geth"
ENV HTTP_PORT="8545"
ENV ENGINE_PORT="8551"
ENV DISCOVERY_PORT="30303"
ENV GETH_BINARY="/usr/local/bin/geth"
ENV GETH_BASE_DATA_DIR="/app/.ethereum"
ENV PORT="3000"

# Install bash, OpenSSL, Node.js, and ts-node
RUN apk add --no-cache bash openssl nodejs npm

# Copy the Geth binary, Nginx configuration, SSL generation script, and other necessary files
COPY --from=base /app/op-geth/build/bin/geth /usr/local/bin/geth

COPY rome-rollup-clients/op-geth/scripts scripts
COPY rome-rollup-clients/op-geth/nginx.conf /etc/nginx/nginx.conf
COPY rome-rollup-clients/op-geth/run.sh ./run.sh

# Expose ports for Nginx and Express server
EXPOSE 80
EXPOSE 443

# Start Geth, Nginx, and the Express server using ts-node
CMD ["bash", "./run.sh"]
