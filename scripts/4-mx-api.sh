
# ---------------------------------------------------------
# MultiversX API Service Installation Functions
# Official Link: https://docs.multiversx.com/sdk-and-tools/rest-api/multiversx-api
# ---------------------------------------------------------

# Function to prepare the MultiversX API environment
MxApi_Prepare_Environment() {
    Log-Step "Prepare MultiversX API Environment"

    local repo_url="https://github.com/multiversx/mx-api-service.git"
    local repo_dir="$HOME/mx-api-service"

    if [ ! -d "$repo_dir" ]; then
        Log "Cloning MultiversX API repository from $repo_url into $repo_dir"
        git clone "$repo_url" "$repo_dir" || {
            Log-Error "Failed to clone repository. Check your network connection."
            return 1
        }
    else
        Log-Warning "Repository already exists at $repo_dir. Skipping clone step."
    fi
}

# Function to install npm if not already installed
MxApi_Install_Npm() {
    Log-Step "Install Npm"

    if ! command -v npm &>/dev/null; then
        Log "Installing Npm..."
        sudo apt update && sudo apt install npm -y || {
            Log-Error "Npm installation failed. Please check your network or package manager settings."
            return 1
        }
    else
        Log "Npm is already installed. Skipping installation."
    fi
}

# Function to install dependencies for the MultiversX API
MxApi_Install_Dependencies() {
    Log-Step "Install MultiversX API dependencies"

    local repo_dir="$HOME/mx-api-service"

    if [ -d "$repo_dir" ]; then
        cd "$repo_dir" || { Log-Error "Failed to navigate to $repo_dir"; return 1; }
        Log "Installing dependencies using Npm"
        npm install || {
            Log-Error "Failed to install dependencies. Check the npm logs for more information."
            return 1
        }
    else
        Log-Error "Repository directory $repo_dir does not exist. Ensure the repository was cloned correctly."
        return 1
    fi
}

# Function to initialize the MultiversX API
MxApi_Initialize() {
    Log-Step "Initialize the MultiversX API plugin structure"

    local repo_dir="$HOME/mx-api-service"

    if [ -d "$repo_dir" ]; then
        cd "$repo_dir" || { Log-Error "Failed to navigate to $repo_dir"; return 1; }
        Log "Initializing the default plugin structure"
        npm run init || {
            Log-Error "Failed to initialize the default plugin structure. Check the npm logs for more information."
            return 1
        }
    else
        Log-Error "Repository directory $repo_dir does not exist. Ensure the repository was cloned correctly."
        return 1
    fi
}