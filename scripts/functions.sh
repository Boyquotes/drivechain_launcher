#!/bin/bash

function startdrivechain {
    if [ $REINDEX -eq 1 ]; then
        echo "drivechain will be reindexed"
        ./mainchain/src/qt/drivechain-qt --reindex --regtest &
    else
        ./mainchain/src/qt/drivechain-qt --regtest &
    fi
    sleep 15s
    
    # Check if drivechain successfully started
    for i in {1..5}; do
        ./mainchain/src/drivechain-cli --regtest getblockcount > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "drivechain successfully started"
            return 0
        fi
        echo "Checking if drivechain has started... attempt $i"
        sleep 5s
    done

    echo "ERROR: drivechain failed to start"
    exit 1
}

function buildchain {
    git pull
    ./autogen.sh

    if [ $INCOMPATIBLE_BDB -ne 1 ]; then
        ./configure
    else
        ./configure --with-incompatible-bdb
    fi

    if [ $? -ne 0 ]; then
        echo "Configure failed!"
        exit 1
    fi

    make -j "$(nproc)"

    if [ $? -ne 0 ]; then
        echo "Make failed!"
        exit 1
    fi

    if [ $SKIP_CHECK -ne 1 ]; then
        make check
        if [ $? -ne 0 ]; then
            echo "Make check failed!"
            exit 1
        fi
    fi
}