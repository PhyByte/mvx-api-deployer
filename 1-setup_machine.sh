#!/bin/bash

# Load variables from env.config
source ./env.config

# Default username fallback in case USERNAME is not set
USERNAME="${USERNAME:-mvx-api}"

# Function to upgrade the system's packages
upgrade_machine() {
    sudo apt -y update && sudo apt -y upgrade
}

# Function to install Docker and Docker Compose
install_docker() {
    sudo apt-get install -y ca-certificates curl gnupg lsb-release

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

    sudo apt -y update
    sudo apt -y install docker-ce docker-ce-cli containerd.io

    sudo curl -L "https://github.com/docker/compose/releases/download/v2.3.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

    docker --version
    docker-compose --version
}

# Function to create a new user
create_new_user() {
    # Create the user specified in the env.config file
    sudo useradd -s /bin/bash -d /home/$USERNAME -m -G sudo $USERNAME

    # Remove the need for a password for the new user
    sudo passwd -d $USERNAME

    # Configure sudo to allow the user to execute commands without a password
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$USERNAME

    # Add the user to the Docker group for Docker access
    sudo usermod -aG docker $USERNAME
}

# Function to transfer the first repo and set up the second repo
transfer_repo_and_setup_second() {
    # Ensure the new user's home directory exists
    if [ ! -d "/home/$USERNAME" ]; then
        echo "Error: User directory for $USERNAME does not exist. Ensure the user is created first."
        exit 1
    fi

    # Copy the first repository to the new user's home directory
    sudo cp -r $(pwd) /home/$USERNAME/mvx-api-deployer

    # Change ownership to the new user
    sudo chown -R $USERNAME:$USERNAME /home/$USERNAME/mvx-api-deployer

    # Delete the old repository
    cd 
    rm -rf /mvx-api-deployer
    echo "Repository transferred, and additional repository cloned for $USERNAME."
}

# Call functions
upgrade_machine
install_docker
create_new_user
transfer_repo_and_setup_second

sudo su - $USERNAME
