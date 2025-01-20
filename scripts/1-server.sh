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
}

# Create a new user with Docker access
# Create a new user with Docker access and copy SSH keys
Create_User() {
    Log-Step "Create a new user with Docker access"

    Log-SubStep "Create a new user"
    sudo useradd -s /bin/bash -d /home/$USERNAME -m -G sudo $USERNAME || Log-Error "Failed to create the new user."

    Log-SubStep "Remove password requirement for the new user"
    sudo passwd -d $USERNAME || Log-Error "Failed to remove password requirement for the user."

    Log-SubStep "Grant passwordless sudo access to the new user"
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$USERNAME || Log-Error "Failed to grant passwordless sudo access."

    Log-SubStep "Add the new user to the Docker group"
    sudo usermod -aG docker $USERNAME || Log-Error "Failed to add the user to the Docker group."

    Log-SubStep "Copy SSH keys to the new user"
    sudo mkdir -p /home/$USERNAME/.ssh || Log-Error "Failed to create .ssh directory."
    sudo cp /root/.ssh/authorized_keys /home/$USERNAME/.ssh/authorized_keys || Log-Error "Failed to copy SSH keys."
    sudo chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh || Log-Error "Failed to set ownership of .ssh directory."
    sudo chmod 700 /home/$USERNAME/.ssh || Log-Error "Failed to set permissions on .ssh directory."
    sudo chmod 600 /home/$USERNAME/.ssh/authorized_keys || Log-Error "Failed to set permissions on authorized_keys."

    Log "SSH keys copied to the new user successfully."
}

# Transfer the repository to the new user
Transfer_Repository() {
    Log-Step "Transfer the ressources to the newly created user"
    Log-SubStep "Transfer the main repository to the new user's home directory"
    # Copy the current repository to the new user's home directory
    sudo cp -r ~/mvx-api-deployer /home/$USERNAME/mvx-api-deployer

    Log-SubStep "Change ownership of the repository to the new user"
    # Change the ownership of the repository to the new user
    sudo chown -R $USERNAME:$USERNAME /home/$USERNAME/mvx-api-deployer

    Log-SubStep "Remove the old repository from the current user"
    # Remove the repository from the current user's home directory to avoid duplication
    rm -rf ~/mvx-api-deployer

    Log "Repository successfully transferred, and the setup for $USERNAME is complete."
}

Append_Bashrc() {
    Log-Step "Append custom bashrc configuration"
    # Append the custom bashrc configuration to the user's .bashrc file
    if [ -f "/home/$USERNAME/mvx-api-deployer/configurationFiles/bashrc" ]; then
        Log "Appending custom bashrc configuration to /home/$USERNAME/.bashrc"
        cat /home/$USERNAME/mvx-api-deployer/configurationFiles/bashrc >>/home/$USERNAME/.bashrc
        source /home/$USERNAME/.bashrc
    else
        Log-Warning "Custom bashrc file not found in /home/$USERNAME/mvx-api-deployer/configurationFiles/"
    fi
}

# Secure SSH configuration
Secure_SSH() {
    Log-Step "Securing SSH Configuration"

    local ssh_config="/etc/ssh/sshd_config"

    Log-SubStep "Changing SSH port to $SSH_PORT"
    sudo sed -i "/^#\?Port/c\Port $SSH_PORT" $ssh_config || Log-Error "Failed to change SSH port."

    Log-SubStep "Disabling password-based login"
    sudo sed -i "/^#\?PasswordAuthentication/c\PasswordAuthentication no" $ssh_config || Log-Error "Failed to disable password authentication."

    Log-SubStep "Disabling root login"
    sudo sed -i "/^#\?PermitRootLogin/c\PermitRootLogin no" $ssh_config || Log-Error "Failed to disable root login."

    Log-SubStep "Allowing only specific users"
    echo "AllowUsers $USERNAME" | sudo tee -a $ssh_config >/dev/null || Log-Error "Failed to restrict users."

    Log-SubStep "Restarting SSH service"
    sudo systemctl restart ssh || Log-Error "Failed to restart SSH service."

    Log "SSH configuration updated successfully."
}

# Disable Ubuntu login
Disable_Ubuntu_Login() {
    Log-Step "Disable Ubuntu User Login"

    sudo passwd -l ubuntu || Log-Error "Failed to lock the ubuntu user account."
    Log "Ubuntu user login disabled successfully."
}


# ---------------------------------------------------------
# Zabbix Monitoring Installation and Management Functions
# ---------------------------------------------------------

zabbixFile="/etc/zabbix/zabbix_agentd.conf"
zabbix_param[1]="Server"
zabbix_param[2]="ServerActive"
zabbix_param[3]="Hostname"

# Install Zabbix Agent
Install_Zabbix() {
    Log-Step "Install Zabbix Agent"

    sudo wget -q https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-6+ubuntu$(lsb_release -rs)_all.deb
    sudo dpkg -i zabbix-release_6.0-6+ubuntu$(lsb_release -rs)_all.deb

    sudo apt update
    sudo apt -y install zabbix-agent || {
        Log-Error "Failed to install Zabbix Agent. Check your network or package manager."
        return 1
    }

    Log "Zabbix Agent installed successfully."
}

# Edit Zabbix Configuration
Edit_Zabbix_Config() {
    Log-Step "Edit Zabbix Configuration"

    for PARAM in "${zabbix_param[@]}"; do
        sed -i '/^'"${PARAM}="'/d' "${zabbixFile}" || {
            Log-Warning "Failed to remove lines starting with '${PARAM}=' from ${zabbixFile}. Continuing..."
        }
    done

    echo "${zabbix_param[1]}=${ZABBIX_SERVER_IP}" >>"${zabbixFile}"
    echo "${zabbix_param[2]}=${ZABBIX_SERVER_IP}" >>"${zabbixFile}"
    echo "${zabbix_param[3]}=${HOSTNAME}" >>"${zabbixFile}"

    Log "Zabbix configuration updated successfully."

    Log-SubStep "Open port for Zabbix Agent"
    sudo ufw allow 10050/tcp || Log-Warning "Failed to open port 10050. Please check your firewall settings."
}

# Restart Zabbix Agent
Restart_Zabbix() {
    Log-Step "Restart Zabbix Agent"

    sudo systemctl restart zabbix-agent || {
        Log-Error "Failed to restart Zabbix Agent."
        return 1
    }
    sudo systemctl enable zabbix-agent || Log-Warning "Failed to enable Zabbix Agent on boot."
    sudo systemctl status zabbix-agent --no-pager || Log-Warning "Failed to retrieve Zabbix Agent status."

    Log "Zabbix Agent restarted and enabled successfully."
}

# Full Setup for Zabbix Agent
Setup_Zabbix_Agent() {
    Install_Zabbix
    Edit_Zabbix_Config
    Restart_Zabbix
}
