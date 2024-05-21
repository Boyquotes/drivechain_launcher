#!/bin/bash

# Source the configuration and functions scripts
source ./config.sh
source ./functions.sh

# Read arguments
SKIP_CLONE=0
SKIP_BUILD=0
SKIP_CHECK=0
SKIP_REPLACE_TIP=0
SKIP_RESTART=0
SKIP_SHUTDOWN=0
INCOMPATIBLE_BDB=0
for arg in "$@"
do
    # Handle arguments
    if [ "$arg" == "--help" ]; then
        echo "The following command line options are available:"
        echo "--skip_clone"
        echo "--skip_build"
        echo "--skip_check"
        echo "--skip_replace_tip"
        echo "--skip_restart"
        echo "--skip_shutdown"
        echo "--with-incompatible-bdb"
        exit
    elif [ "$arg" == "--skip_clone" ]; then
        SKIP_CLONE=1
    elif [ "$arg" == "--skip_build" ]; then
        SKIP_BUILD=1
    elif [ "$arg" == "--skip_check" ]; then
        SKIP_CHECK=1
    elif [ "$arg" == "--skip_replace_tip" ]; then
        SKIP_REPLACE_TIP=1
    elif [ "$arg" == "--skip_restart" ]; then
        SKIP_RESTART=1
    elif [ "$arg" == "--skip_shutdown" ]; then
        SKIP_SHUTDOWN=1
    elif [ "$arg" == "--with-incompatible-bdb" ]; then
        INCOMPATIBLE_BDB=1
    fi
done

# Display warning
clear
echo -e "\e[32mYou should probably run this in a VM\e[0m"
echo

# Clone repositories
if [ $SKIP_CLONE -ne 1 ]; then
    echo "Cloning repositories"
    git clone https://github.com/LayerTwo-labs/mainchain.git
fi

# Build repositories
if [ $SKIP_BUILD -ne 1 ]; then
    cd mainchain
    buildchain
    cd ..
fi

# Create configuration files
echo "Create drivechain configuration file"
mkdir -p ~/.drivechain/
touch ~/.drivechain/drivechain.conf
echo "rpcuser=drivechain" > ~/.drivechain/drivechain.conf
echo "rpcpassword=integrationtesting" >> ~/.drivechain/drivechain.conf
echo "server=1" >> ~/.drivechain/drivechain.conf


read -p "Are you sure you want to run this? (yes/no): " WARNING_ANSWER
if [ "$WARNING_ANSWER" != "yes" ]; then
    exit
fi

# Start drivechain and perform initial setup
startdrivechain

echo -e "\e[32mdrivechain integration testing completed!\e[0m"