# ---------------------------------------------------------
# MultiversX API Deployer - Server Preparation Functions
# ---------------------------------------------------------

# --------- FUNCTIONS ---------

# Upgrade the system's packages
Upgrade_System() {
    Log-Step "Upgrade the system's packages"
    Log-SubStep "Update the package list"
    # Update the package list to ensure the latest package information is fetched
    sudo apt-get update

    Log-SubStep "Upgrade the installed packages"
    # Upgrade all installed packages to their latest versions
    sudo apt-get upgrade -y
}

# Install Docker and Docker Compose
Install_Docker() {
    Log-Step "Install Docker and Docker Compose"

    Log-SubStep "Install prerequisites for Docker"
    # Install required packages for Docker installation
    sudo apt-get update -y
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

    Log-SubStep "Add Docker's official GPG key"
    # Add the Docker GPG key to verify Docker packages
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    Log-SubStep "Add Docker repository to APT sources"
    # Add Docker's official repository to the package manager's source list
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

    Log-SubStep "Update package list to include Docker repository"
    # Update the package list again to include Docker packages
    sudo apt-get update -y

    Log-SubStep "Install Docker and its CLI tools"
    # Install Docker, Docker CLI, and containerd
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io

    Log-SubStep "Install Docker Compose"
    # Install Docker Compose plugin
    sudo apt-get install -y docker-compose-plugin

    Log-SubStep "Verify Docker and Docker Compose installation"
    # Verify the installation by checking the versions
    docker --version
    docker compose version
}

Append_Bashrc() {
    Log-Step "Append custom bashrc configuration"
    # Append the custom bashrc configuration to the user's .bashrc file
    if [ -f "/home/$USERNAME/mvx-api-deployer/config/bashrc" ]; then
        Log "Appending custom bashrc configuration to /home/$USERNAME/.bashrc"
        cat /home/$USERNAME/mvx-api-deployer/config/bashrc >>/home/$USERNAME/.bashrc
    else
        Log-Warning "Custom bashrc file not found in /home/$USERNAME/mvx-api-deployer/config/"
    fi
}
