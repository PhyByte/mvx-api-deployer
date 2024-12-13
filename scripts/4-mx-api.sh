# ---------------------------------------------------------
# MultiversX API Service Installation Functions
# Official Link: https://docs.multiversx.com/sdk-and-tools/rest-api/multiversx-api
# ---------------------------------------------------------

# Function to prepare the MultiversX API environment
MxApi_Prepare_Environment() {
    Log-Step "Prepare MultiversX API Environment"

    local repo_url="https://github.com/multiversx/mx-api-service.git"
    local repo_dir="$HOME/mx-api-service"

    # Clone the MultiversX API repository if it doesn't exist
    if [ ! -d "$repo_dir" ]; then
        Log-SubStep "Clone MultiversX API Repository"
        git clone "$repo_url" "$repo_dir" || {
            Log-Error "Failed to clone MultiversX API repository."
            return 1
        }
        Log "Repository cloned successfully."
    else
        Log-Warning "Repository already exists at $repo_dir. Skipping clone step."
    fi
}

# Function to install npm if not already installed
MxApi_Install_Npm() {
    Log-Step "Install Npm"

    if ! command -v npm &>/dev/null; then
        Log-SubStep "Install Npm Package Manager"
        sudo apt update && sudo apt install npm -y || {
            Log-Error "Npm installation failed. Please check your network or package manager settings."
            return 1
        }
        Log "Npm installed successfully."
    else
        Log "Npm is already installed. Skipping installation."
    fi
}

# Function to install dependencies for the MultiversX API
MxApi_Install_Dependencies() {
    Log-Step "Install MultiversX API Dependencies"

    local repo_dir="$HOME/mx-api-service"

    if [ -d "$repo_dir" ]; then
        cd "$repo_dir" || {
            Log-Error "Failed to navigate to $repo_dir."
            return 1
        }
        Log "Installing dependencies using Npm"
        npm install || {
            Log-Error "Failed to install dependencies. Check the npm logs for more information."
            return 1
        }
        Log "Dependencies installed successfully."
    else
        Log-Error "Repository directory $repo_dir does not exist. Ensure the repository was cloned correctly."
        return 1
    fi
}

# Function to initialize the MultiversX API
MxApi_Initialize() {
    Log-Step "Initialize MultiversX API Plugin Structure"

    local repo_dir="$HOME/mx-api-service"

    if [ -d "$repo_dir" ]; then
        cd "$repo_dir" || {
            Log-Error "Failed to navigate to $repo_dir."
            return 1
        }
        Log "Initializing the default plugin structure"
        npm run init || {
            Log-Error "Failed to initialize the default plugin structure. Check the npm logs for more information."
            return 1
        }
        Log "Default plugin structure initialized successfully."
    else
        Log-Error "Repository directory $repo_dir does not exist. Ensure the repository was cloned correctly."
        return 1
    fi
}

# Function to create and start the systemd service
MxApi_Setup_Service() {
    Log-Step "Setup MultiversX API Systemd Service"

    local service_file="/etc/systemd/system/multiversx-api.service"
    local repo_dir="$HOME/mx-api-service"

    # Create the systemd service file
    Log-SubStep "Create Systemd Service File"
    sudo bash -c "cat <<EOF > $service_file
[Unit]
Description=MultiversX API Service
After=network.target

[Service]
Type=simple
User=$USERNAME
WorkingDirectory=$repo_dir
ExecStart=/usr/bin/npm run start:mainnet
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF"

    # Reload systemd and start the service
    Log-SubStep "Enable and Start the MultiversX API Service"
    sudo systemctl daemon-reload
    sudo systemctl enable multiversx-api.service
    sudo systemctl start multiversx-api.service || {
        Log-Error "Failed to start the MultiversX API service."
        return 1
    }

    Log "MultiversX API service setup completed successfully."
}

# Function to check the status of the MultiversX API service
MxApi_Check_Status() {
    Log-Step "Check MultiversX API Service Status"

    if systemctl is-active --quiet multiversx-api.service; then
        Log "MultiversX API service is running."
    else
        Log-Warning "MultiversX API service is not running."
        sudo journalctl -u multiversx-api.service --since "5 minutes ago"
    fi
}

# Main function to install and setup MultiversX API
MxApi_Install_All() {
    MxApi_Prepare_Environment
    MxApi_Install_Npm
    MxApi_Install_Dependencies
    MxApi_Initialize
    MxApi_Setup_Service
    MxApi_Check_Status
}
