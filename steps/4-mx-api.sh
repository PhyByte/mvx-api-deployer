
MxApi_Install() {
    Log-Step "Install MultiversX API"

    # Step 1: Clone the repository
    Log-SubStep "Clone the MultiversX API repository"
    local repo_url="https://github.com/multiversx/mx-api-service.git"
    local repo_dir="$HOME/mx-api-service"

    if [ ! -d "$repo_dir" ]; then
        Log "Cloning repository from $repo_url into $repo_dir"
        git clone "$repo_url" "$repo_dir"
        if [ $? -eq 0 ]; then
            Log "Repository cloned successfully."
        else
            Log-Error "Failed to clone the repository from $repo_url."
            return 1
        fi
    else
        Log-Warning "Repository already exists at $repo_dir. Skipping clone step."
    fi

    # Step 2: Install Npm
    Log-SubStep "Install Npm"
    if ! command -v npm &>/dev/null; then
        Log "Installing Npm..."
        sudo apt update && sudo apt install npm -y
        if [ $? -eq 0 ]; then
            Log "Npm installed successfully."
        else
            Log-Error "Failed to install Npm. Check your network or package manager settings."
            return 1
        fi
    else
        Log "Npm is already installed. Skipping installation."
    fi

    # Step 3: Navigate to the repository directory
    Log-SubStep "Navigate to the MultiversX API repository directory"
    if [ -d "$repo_dir" ]; then
        cd "$repo_dir"
        Log "Navigated to $repo_dir."
    else
        Log-Error "Repository directory $repo_dir does not exist. Ensure the repository was cloned correctly."
        return 1
    fi

    # Step 4: Install the MultiversX API dependencies
    Log-SubStep "Install the MultiversX API dependencies using Npm"
    npm install
    if [ $? -eq 0 ]; then
        Log "Dependencies installed successfully."
    else
        Log-Error "Failed to install dependencies. Check the npm logs for more information."
        return 1
    fi

    # Step 5: Initialize the default plugin structure
    Log-SubStep "Create default plugin structure"
    npm run init
    if [ $? -eq 0 ]; then
        Log "Default plugin structure initialized successfully."
    else
        Log-Error "Failed to initialize the default plugin structure. Check the npm logs for more information."
        return 1
    fi

    Log "MultiversX API installation completed successfully."
}
