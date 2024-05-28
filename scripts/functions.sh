#!/bin/bash

export RPC_USER="drivechain"
export RPC_PASSWORD="L2L"
export RPC_HOST="127.0.0.1"
export RPC_PORT="18443"
export CONFIG_FILE="$HOME/.drivechain/drivechain.conf"

function startdrivechain {
    if [ $REINDEX -eq 1 ]; then
        echo "drivechain will be reindexed"
        ./mainchain/src/drivechaind --reindex --regtest -conf=$CONFIG_FILE &
    else
        ./mainchain/src/drivechaind --regtest -conf=$CONFIG_FILE &
    fi
    sleep 15s
    
    # Check if drivechain has started using curl
    for i in {1..5}; do
        curl --user "${RPC_USER}:${RPC_PASSWORD}" -d '{"method": "getblockcount", "params": []}' http://${RPC_HOST}:${RPC_PORT}/ > /dev/null
        if [ $? -eq 0 ]; then
            echo "drivechain curl successfully started"
            break 
        fi
        echo "Checking if drivechain has started (curl)... attempt $i"
        sleep 5s
    done

    if [ $? -ne 0 ]; then
        echo "ERROR: drivechain failed to start with curl"
        exit 1
    fi

    # Check if drivechain has started using CLI
    for i in {1..5}; do
        ./mainchain/src/drivechain-cli -conf=$CONFIG_FILE getblockcount > /dev/null
        if [ $? -eq 0 ]; then
            echo "drivechain cli successfully started"
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
}


