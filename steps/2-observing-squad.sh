ObsSquad_Prepare_Environment() {
    Log-SubStep "Prepare Observing Squad Environment"

    # Step 1: Clone the MultiversX chain scripts repository
    local repo_dir="$HOME/mx-chain-scripts"
    local config_file="$repo_dir/config/variables.cfg"

    if [ ! -d "$repo_dir" ]; then
        Log "Cloning MultiversX chain scripts repository into $repo_dir"
        git clone https://github.com/multiversx/mx-chain-scripts.git "$repo_dir"
    else
        Log "Repository already cloned. Skipping clone step."
    fi

    # Step 2: Modify variables.cfg
    if [ ! -f "$config_file" ]; then
        Log-Error "Configuration file $config_file not found. Exiting."
        return 1
    fi

    # Replace variables in the configuration file
    sed -i "s/^ENVIRONMENT=\".*\"/ENVIRONMENT=\"$NETWORK\"/" "$config_file"
    sed -i "s|^CUSTOM_HOME=.*|CUSTOM_HOME=\"$HOME\"|" "$config_file"
    sed -i "s/^CUSTOM_USER=.*$/CUSTOM_USER=\"$USERNAME\"/" "$config_file"

    Log "Updated variables.cfg:"
    grep -E "ENVIRONMENT|CUSTOM_HOME|CUSTOM_USER" "$config_file"
}

# Function that install the observing squad and press enter to all the questions
ObsSquad_Install() {
    Log-SubStep "Install Observing Squad"

    local script_dir="$HOME/mx-chain-scripts"
    local script_file="$script_dir/script.sh"

    # Verify the directory exists
    if [ ! -d "$script_dir" ]; then
        Log-Error "Directory $script_dir does not exist. Clone the repository first."
        return 1
    fi

    # Verify the script file exists
    if [ ! -f "$script_file" ]; then
        Log-Error "Script file $script_file does not exist."
        return 1
    fi

    # Run the script and automatically approve prompts
    yes "" | "$script_file" observing_squad
    if [ $? -eq 0 ]; then
        Log "Observing Squad installation completed successfully."
    else
        Log-Error "Observing Squad installation failed."
        return 1
    fi
}

# Function that copy the external.toml file to the different node folders
ObsSquad_Activate_Indexer() {
    Log-SubStep "Activate Indexer Configuration for Nodes"

    # Define base paths
    local source_file="/home/$USERNAME/mvx-api-deployer/configurationFiles/external.toml"
    local nodes_base_dir="$HOME/elrond-nodes"

    # Ensure the source file exists
    if [ ! -f "$source_file" ]; then
        Log-Error "Source file $source_file does not exist."
        return 1
    fi

    # Replace external.toml for each node
    for node in node-{0..3}; do
        local target_dir="$nodes_base_dir/$node/config"
        if [ -d "$target_dir" ]; then
            cp "$source_file" "$target_dir/external.toml"
            Log "Copied external.toml to $target_dir"
        else
            Log-Warning "Target directory $target_dir does not exist. Skipping."
        fi
    done

    Log "Indexer configuration activated successfully for available nodes."
}
