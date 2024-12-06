#!/bin/bash

upgrade_machine() {
    sudo apt -y update && sudo apt -y upgrade
}

install_docker() {

    sudo apt-get install ca-certificates curl gnupg lsb-release
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

create_new_user() {
    sudo useradd -s /bin/bash -d /home/mvx-api -m -G sudo mvx-api
    sudo passwd mvx-api

    # Add Gitlab Runner user to the docker group
    sudo usermod -aG docker mvx-api

    # login to user and clone the repository
    su - mvx-api
    git clone https://gitlab.com/phybyte/mvx-api-deployer.git
    git clone https://github.com/multiversx/mx-chain-mainnet-config.git
}




# Call all function in order

upgrade_machine
install_docker
create_new_user
