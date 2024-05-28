#!/bin/bash

export RPC_USER="drivechain"
export RPC_PASSWORD="integrationtesting"
export RPC_HOST="127.0.0.1"
export RPC_PORT="18443"
export CONFIG_FILE="$HOME/.drivechain/drivechain.conf"


function startdrivechain {

    # Ensure required binaries are present
    if [ ! -f ./mainchain/src/qt/drivechain-qt ]; then
        echo "ERROR: drivechain-qt binary not found"
        exit 1
    fi
    if [ ! -f ./mainchain/src/drivechain-cli ]; then
        echo "ERROR: drivechain-cli binary not found"
        exit 1
    fi

    if [ $REINDEX -eq 1 ]; then
        echo "drivechain will be reindexed"
        ./mainchain/src/qt/drivechain-qt --reindex --regtest -conf=$CONFIG_FILE &
    else
        ./mainchain/src/qt/drivechain-qt --regtest -conf=$CONFIG_FILE &
    fi
    sleep 15s
    
    # Check if drivechain has started using curl
    for i in {1..5}; do
        curl --user "${RPC_USER}:${RPC_PASSWORD}" --data-binary '{"jsonrpc": "1.0", "id":"curltest", "method": "getblockcount", "params": [] }' -H 'content-type: text/plain;' http://${RPC_HOST}:${RPC_PORT}/ > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "drivechain successfully started (curl)"
            break
        fi
        echo "Checking if drivechain has started (curl)... attempt $i"
        sleep 5s
    done

    if [ $? -ne 0 ]; then
        echo "ERROR: drivechain failed to start with curl"
        exit 1
    fi

    # Check if drivechain has started using drivechain-cli
    for i in {1..5}; do
        ./mainchain/src/drivechain-cli -conf=$CONFIG_FILE getblockcount > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "drivechain successfully started (cli)"
            break 
        fi
        echo "Checking if drivechain has started (cli)... attempt $i"
        sleep 5s
    done

    if [ $? -ne 0 ]; then
        echo "ERROR: drivechain failed to start with cli"
        exit 1
    fi

    echo "drivechain node started successfully with both curl and cli"
    exit 0
}
