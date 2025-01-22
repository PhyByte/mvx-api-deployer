# Clone required repositories
xExchange_Prepare_Environment() {
    Log-Step "Prepare xExchange Environment"

    local repo_url="https://github.com/multiversx/mx-exchange-service.git"
    local repo_dir="$HOME/mx-exchange-service"

    # Clone the MultiversX xExchange repository if it doesn't exist
    if [ ! -d "$repo_dir" ]; then
        Log-SubStep "Clone MultiversX xExchange Repository"
        git clone "$repo_url" "$repo_dir" || {
            Log-Error "Failed to clone MultiversX xExchange repository."
            return 1
        }
        Log "Repository cloned successfully."
    else
        Log-Warning "Repository already exists at $repo_dir. Skipping clone step."
    fi

    # Install npm
    Log-SubStep "Install npm"
    sudo apt install -y npm || {
        Log-Error "Failed to install npm."
        return 1
    }
}

xExchange_Copy_Configuration() {
    Log-Step "Copy xExchange Configuration"

    local source_dir="$HOME/mvx-api-deployer/config/$NETWORK/2-mx-exchange-service"
    local repo_dir="$HOME/mx-exchange-service"

    Log-SubStep "Copy docker-compose.yml file"
    cp -f "$source_dir/docker-compose.yml" "$repo_dir/docker-compose.yml" || {
        Log-Error "Failed to copy docker-compose.yml file."
        return 1
    }

    Log-SubStep "Copy xExchange .env file"
    cp -f "$source_dir/.env" "$repo_dir/.env" || {
        Log-Error "Failed to copy xExchange .env file."
        return 1
    }
    Log "xExchange configuration files copied successfully."
}
xExchange_Overwrite_Sll_configuration() {
    Log-Step "Overwrite SSL configuration file"

    local source_dir="$HOME/mvx-api-deployer/config/$NETWORK/2-mx-exchange-service"
    local repo_dir="$HOME/mx-exchange-service"
    local config_file="$source_dir/timescaledb.module.ts"

    if [ ! -f "$config_file" ]; then
        Log-Error "ssl file $config_file not found. Exiting."
        return 1
    fi

    cp -f "$config_file" "$repo_dir/src/services/analytics/timescaledb/timescaledb.module.ts" || {
        Log-Error "Failed to copy ssl file."
        return 1
    }
}

xExchange_Build() {
    Log-Step "Build xExchange"

    local repo_dir="$HOME/mx-exchange-service"

    cd "$repo_dir" || {
        Log-Error "Failed to navigate to $repo_dir."
        return 1
    }
    Log "Navigated to $repo_dir"

    Log-SubStep "Build xExchange"
    npm install || {
        Log-Error "Failed to build xExchange."
        return 1
    }
    sudo docker compose up -d || {
        Log-Error "Failed to start xExchange services. Check Docker Compose logs for details."
        return 1
    }
}

xExchange_Create_Service() {
    Log-Step "Enable Systemd Service for xExchange"

    local service_file="/etc/systemd/system/mvx-exchange.service"

    Log-SubStep "Copy xExchange Service File"
    sudo cp "$HOME/mvx-api-deployer/config/$NETWORK/2-mx-exchange-service/mvx-exchange.service" "$service_file" || {
        Log-Error "Failed to copy xExchange Indexer service file."
        return 1
    }

    Log-SubStep "Enable xExchange Service"
    sudo systemctl daemon-reload
    sudo systemctl enable mvx-exchange || {
        Log-Error "Failed to enable xExchange service."
        return 1
    }
}
