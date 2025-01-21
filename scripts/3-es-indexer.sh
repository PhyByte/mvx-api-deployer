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
    Log "Repository cloned successfully."
    else
        Log-Warning "Repository already exists at $repo_dir. Skipping clone step."
    fi

}

EsIndexer_Copy_Configuration() {
    Log-Step "Copy ElasticSearch Indexer Configuration"

    local source_dir="$HOME/mvx-api-deployer/configurationFiles/services/1-mx-chain-es-indexer-go"
    local repo_dir="$HOME/mx-chain-es-indexer-go"


    Log-SubStep "Copy docker compose file"
    cp -f "$source_dir/docker-compose.yml" "$repo_dir/docker-compose.yml" || {
        Log-Error "Failed to copy docker compose file."
        return 1
    }

    Log-SubStep "Copy ElasticSearch Indexer service configuration files"
    cp -f "$source_dir/cmd/elasticindexer/"*.toml "$repo_dir/cmd/elasticindexer/" || {
        Log-Error "Failed to copy ElasticSearch Indexer configuration files."
        return 1
    }
    Log "ElasticSearch Indexer configuration files copied successfully."
}

# Build and configure the ElasticSearch Indexer
EsIndexer_Build() {
    Log-Step "Build ElasticSearch Indexer"

    local repo_dir="$HOME/mx-chain-es-indexer-go"
    local cmd_dir="$repo_dir/cmd/elasticindexer"

    Log "Pull the docker images"
    cd "$repo_dir" && sudo docker compose pull
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
    go install || {
        Log-Error "Failed to install Go dependencies for ElasticSearch Indexer."
        return 1
    }
    go build -o elasticindexer || {
        Log-Error "Failed to build ElasticSearch Indexer executable."
        return 1
    }

    Log "ElasticSearch Indexer executable built successfully."
}

# Enable the systemd service for ElasticSearch Indexer
EsIndexer_Create_Service() {
    Log-Step "Enable Systemd Service for ElasticSearch Indexer"

    local service_file="/etc/systemd/system/mvx-elasticindexer.service"

    Log-SubStep "Copy ElasticSearch Indexer Service File"
    sudo cp "$HOME/mvx-api-deployer/configurationFiles/services/1-mx-chain-es-indexer-go/mvx-elasticindexer.service" "$service_file" || {
        Log-Error "Failed to copy ElasticSearch Indexer service file."
        return 1
    }

    Log-SubStep "Enable ElasticSearch Indexer Service"
    sudo systemctl daemon-reload
    sudo systemctl enable mvx-elasticindexer || {
        Log-Error "Failed to enable ElasticSearch Indexer service."
        return 1
    }
    # sudo systemctl start mvx-elasticindexer || {
    #     Log-Error "Failed to start ElasticSearch Indexer service."
    #     return 1
    # }

    # Verify the service is running
    # sudo systemctl status mvx-elasticindexer --no-pager || {
    #     Log-Error "ElasticSearch Indexer service failed to start. Check logs with 'journalctl -u mvx-elasticindexer'."
    #     return 1
    # }

    Log "ElasticSearch Indexer systemd service configured and enabled."
}
