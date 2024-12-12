Install_Prerequisites_And_Create_User() {
    # ---------------------------------------------------------
    #  Step 1: Upgrade the system's packages
    # ---------------------------------------------------------
    Log-Step "Upgrade the system's packages"
    Log-SubStep "Update the package list"
    # Update the package list to ensure the latest package information is fetched
    sudo apt-get update

    Log-SubStep "Upgrade the installed packages"
    # Upgrade all installed packages to their latest versions
    sudo apt-get upgrade -y

    # ---------------------------------------------------------
    #  Step 2: Install Docker and Docker Compose
    # ---------------------------------------------------------
    Log-Step "Install Docker and Docker Compose"
    Log-SubStep "Install prerequisites for Docker"
    # Install required packages for Docker installation
    sudo apt-get install -y ca-certificates curl gnupg lsb-release

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
    sudo apt -y update

    Log-SubStep "Install Docker and its CLI tools"
    # Install Docker, Docker CLI, and containerd
    sudo apt -y install docker-ce docker-ce-cli containerd.io

    Log-SubStep "Install Docker Compose"
    # Download and install Docker Compose from GitHub
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.3.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

    Log-SubStep "Verify Docker and Docker Compose installation"
    # Verify the installation by checking the versions
    docker --version
    docker-compose --version

    # ---------------------------------------------------------
    #  Step 3: Create a new user with Docker access
    # ---------------------------------------------------------
    Log-Step "Create a new user with Docker access"
    Log-SubStep "Create a new user"
    # Create a new user with specified home directory and add to the sudo group
    sudo useradd -s /bin/bash -d /home/$USERNAME -m -G sudo $USERNAME

    Log-SubStep "Remove password requirement for the new user"
    # Remove the password requirement for the new user
    sudo passwd -d $USERNAME

    Log-SubStep "Grant passwordless sudo access to the new user"
    # Configure sudoers to allow the new user to execute commands without a password
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$USERNAME

    Log-SubStep "Add the new user to the Docker group"
    # Add the new user to the Docker group for Docker access
    sudo usermod -aG docker $USERNAME

    Log-Step "Transfer the ressources to the newly created user"
    Log-SubStep "Transfer the main repository to the new user's home directory"
    # Copy the current repository to the new user's home directory
    sudo cp -r $(pwd) /home/$USERNAME/mvx-api-deployer

    Log-SubStep "Change ownership of the repository to the new user"
    # Change the ownership of the repository to the new user
    sudo chown -R $USERNAME:$USERNAME /home/$USERNAME/mvx-api-deployer

    Log-SubStep "Remove the old repository from the current user"
    # Remove the repository from the current user's home directory to avoid duplication
    cd
    rm -rf /mvx-api-deployer

    Log "Repository successfully transferred, and the setup for $USERNAME is complete."

    # ---------------------------------------------------------
    #  Step 4: Login to the new user
    # ---------------------------------------------------------
    Log-Step "Login to the new user: ${USERNAME}"
    sudo su - $USERNAME
    Log-SubStep "Update the .bashrc file for the new user"
    # Append the custom bashrc configuration to the new user's .bashrc file
    if [ -f "/home/$USERNAME/mvx-api-deployer/configurationFiles/bashrc" ]; then
        Log "Appending custom bashrc configuration to /home/$USERNAME/.bashrc"
        cat /home/$USERNAME/mvx-api-deployer/configurationFiles/bashrc >>/home/$USERNAME/.bashrc
    else
        Log-Warning "Custom bashrc file not found in /home/$USERNAME/mvx-api-deployer/configurationFiles/"
    fi

    Log-SubStep "Ensure .bashrc is sourced in .bash_profile"
    # Ensure .bashrc is sourced in the user's .bash_profile
    echo "source /home/$USERNAME/.bashrc" >>/home/$USERNAME/.bashrc

    Log-SubStep "Reload the new user's .bashrc file"
    # Reload the .bashrc file to apply the changes
    source /home/$USERNAME/.bashrc

    Log "Custom bashrc configuration applied successfully for ${USERNAME}."

}
