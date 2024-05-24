function startdrivechain {
    config_file=$1

    if [ $REINDEX -eq 1 ]; then
        echo "drivechain will be reindexed"
        ./mainchain/src/qt/drivechain-qt --reindex --regtest -conf=$config_file &
    else
        ./mainchain/src/qt/drivechain-qt --regtest -conf=$config_file &
    fi
    sleep 15s
    
    # start check 
    for i in {1..5}; do
        ./mainchain/src/drivechain-cli -conf=$config_file getblockcount > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "drivechain successfully started"
            break 
        fi
        echo "Checking if drivechain has started... attempt $i"
        sleep 5s
    done

    if [ $? -ne 0 ]; then
        echo "ERROR: drivechain failed to start"
        exit 1
    fi

    testL1 $config_file
    
    if [ $? -ne 0 ]; then
        echo "ERROR: L1 tests failed"
        exit 1
    fi
    exit 0
}

function testL1 {
    config_file=$1

    # mining tests
    echo "Mining 1 block..."
    ./mainchain/src/drivechain-cli -conf=$config_file generatetoaddress 1 $(./mainchain/src/drivechain-cli -conf=$config_file getnewaddress) > /dev/null
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to mine 1 block"
        exit 1
    fi
    echo "Successfully mined 1 block"

    echo "Mining 100 blocks..."
    ./mainchain/src/drivechain-cli -conf=$config_file generatetoaddress 100 $(./mainchain/src/drivechain-cli -conf=$config_file getnewaddress) > /dev/null
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to mine 100 blocks"
        exit 1
    fi

    echo "Successfully mined 100 blocks"
    exit 0
}