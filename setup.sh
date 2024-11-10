#!/bin/bash

NODENAME="blockmesh"
NODEPATH=""
GREENCOLOR="\e[32m"
DEFAULTCOLOR="\e[0m"

setup() {
    curl -s https://raw.githubusercontent.com/Widiskel/Widiskel/refs/heads/main/show_logo.sh | bash
    sleep 3

    echo "Updating & Upgrading Packages..."
    sudo apt update -y && sudo apt upgrade -y

    cd $HOME
    if [ -d "node" ]; then
        echo "The 'node' directory already exists."
    else
        mkdir node
        echo "Created the 'node' directory."
    fi
    cd node

    if [ -d "$NODENAME" ]; then
        echo "The '$NODENAME' directory already exists."
    else
        mkdir $NODENAME
        echo "Created the '$NODENAME' directory."
    fi
    cd $NODENAME

    if [ -d "target" ]; then
        rm -rf target
    fi
}

installRequirements(){
    echo "Installing $NODENAME Compute Node"
    ARCH=$(uname -m)

    if [ "$ARCH" == "arm64" ] || [ "$ARCH" == "aarch64" ]; then
        echo "Architecture is arm64, downloading arm64 version."
        curl -L -o $NODENAME-cli.tar.gz https://github.com/block-mesh/block-mesh-monorepo/releases/download/v0.0.352/blockmesh-cli-aarch64-unknown-linux-gnu.tar.gz
        NODEPATH="$HOME/node/$NODENAME/target/aarch64-unknown-linux-gnu/release"
    elif [ "$ARCH" == "x86_64" ]; then
        echo "Architecture is x86_64, downloading amd64 version."
        curl -L -o $NODENAME-cli.tar.gz https://github.com/block-mesh/block-mesh-monorepo/releases/download/v0.0.352/blockmesh-cli-x86_64-unknown-linux-gnu.tar.gz
        NODEPATH="$HOME/node/$NODENAME/target/x86_64-unknown-linux-gnu/release"
    else
        echo "Unknown architecture: $ARCH. Exiting."
        exit 1
    fi
    
    echo "Extracting $NODENAME-cli.tar.gz..."
    if tar -xvzf "$NODENAME-cli.tar.gz"; then
        echo "$NODENAME CLI Node Installed Successfully"
    else
        echo "Extraction failed. Exiting."
        exit 1
    fi
}

finish() {
    if ! [ -f help.txt ]; then
        {
            echo "Setup Complete"
            echo "Your $NODENAME path is on $NODEPATH"
            echo ""
            echo "Follow this guide to start your node:"
            echo "To start Your Node run $NODEPATH/$NODENAME-cli --email YOUREMAIL --password YOURPASSWORD"
        } > help.txt
    fi
    cat help.txt
}

run() {
    read -p "Do you want to run it? (y/n): " response
    if [[ $response == "y" ]]; then
        echo -e "\nEnter your credentials:"
        read -p "Email: " EMAIL
        read -s -p "Password: " PASSWORD
        echo
        cd $NODEPATH
        ./$NODENAME-cli --email "$EMAIL" --password "$PASSWORD"
    else
        echo "LFG"
    fi
}

setup
installRequirements
finish
run
