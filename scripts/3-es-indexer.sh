
# ---------------------------------------------------------
# ElasticSearch Indexer Installation Functions
# Official Link: https://docs.multiversx.com/sdk-and-tools/indexer/#observer-client
# ---------------------------------------------------------

# Prepare the environment for the ElasticSearch Indexer
EsIndexer_Prepare_Environment() {
    Log-Step "Prepare ElasticSearch Indexer Environment"

    local repo_url="https://github.com/multiversx/mx-chain-es-indexer-go.git"
    local repo_dir="$HOME/mx-chain-es-indexer-go"

    # Clone the repository if it doesn't exist
    if [ ! -d "$repo_dir" ]; then
        Log-SubStep "Clone ElasticSearch Indexer Repository"
        Log "Cloning repository from $repo_url into $repo_dir"
        git clone "$repo_url" "$repo_dir" || {
            Log-Error "Failed to clone the ElasticSearch Indexer repository. Check your network connection."
            return 1
        }
    else
        Log-Warning "Repository already exists at $repo_dir. Skipping clone step."
    fi
}

# Install Go and verify the environment
EsIndexer_Install_Go() {
    Log-Step "Install Go Language for ElasticSearch Indexer"

    # Install Go if it's not already installed
    if ! command -v go &>/dev/null; then
        Log-SubStep "Install Go Language"
        Log "Installing Go language..."
        sudo apt update && sudo apt install golang-go -y || {
            Log-Error "Go installation failed. Please check your setup."
            return 1
        }
    else
        Log "Go is already installed. Skipping installation."
    fi
}

# Build and configure the ElasticSearch Indexer
EsIndexer_Build() {
    Log-Step "Build ElasticSearch Indexer"

    local repo_dir="$HOME/mx-chain-es-indexer-go"
    local cmd_dir="$repo_dir/cmd/elasticindexer"

    # Verify the command directory exists
    if [ ! -d "$cmd_dir" ]; then
        Log-Error "Directory $cmd_dir does not exist. Ensure the repository was cloned correctly."
        return 1
    fi

    cd "$cmd_dir" || {
        Log-Error "Failed to navigate to $cmd_dir."
        return 1
    }
    Log "Navigated to $cmd_dir"

    # Build the ElasticSearch Indexer executable
    Log-SubStep "Compile ElasticSearch Indexer Executable"
    go build -o elasticindexer || {
        Log-Error "Failed to build ElasticSearch Indexer executable."
        return 1
    }

    # Set executable permissions
    chmod +x elasticindexer || {
        Log-Error "Failed to set executable permissions for elasticindexer."
        return 1
    }

    Log "ElasticSearch Indexer executable built successfully."
}

# Create and enable the systemd service for ElasticSearch Indexer
EsIndexer_Create_Service() {
    Log-Step "Create and Enable Systemd Service for ElasticSearch Indexer"

    local cmd_dir="$HOME/mx-chain-es-indexer-go/cmd/elasticindexer"
    local service_file="/etc/systemd/system/elasticindexer.service"

    # Create the systemd service file
    if [ ! -f "$service_file" ]; then
        Log-SubStep "Create Systemd Service File"
        Log "Creating systemd service file at $service_file"
        cat <<EOF | sudo tee "$service_file"
[Unit]
Description=ElasticSearch Indexer
After=network.target

[Service]
Type=simple
User=$USERNAME
WorkingDirectory=$cmd_dir
ExecStart=$cmd_dir/elasticindexer
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
    else
        Log-Warning "Systemd service file already exists at $service_file. Skipping creation."
    fi

    # Enable and start the systemd service
    Log-SubStep "Enable and Start ElasticSearch Indexer Service"
    sudo systemctl daemon-reload
    sudo systemctl enable elasticindexer || {
        Log-Error "Failed to enable ElasticSearch Indexer service."
        return 1
    }
    sudo systemctl start elasticindexer || {
        Log-Error "Failed to start ElasticSearch Indexer service."
        return 1
    }

    # Verify the service is running
    sudo systemctl status elasticindexer --no-pager || {
        Log-Error "ElasticSearch Indexer service failed to start. Check logs with 'journalctl -u elasticindexer'."
        return 1
    }

    Log "ElasticSearch Indexer systemd service configured and running."
}