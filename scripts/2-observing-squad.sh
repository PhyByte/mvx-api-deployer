# ---------------------------------------------------------
# Observing Squad Installation Functions
# Official Link: https://docs.multiversx.com/integrators/observing-squad
# ---------------------------------------------------------

# Prepare the Observing Squad Environment
ObsSquad_Prepare_Environment() {
    Log-Step "Prepare Observing Squad Environment"

    local repo_dir="$HOME/mx-chain-scripts"
    local config_file="$repo_dir/config/variables.cfg"

    if [ ! -d "$repo_dir" ]; then
        Log-SubStep "Clone the MultiversX chain scripts repository"
        git clone https://github.com/multiversx/mx-chain-scripts.git "$repo_dir"
    else
        Log "Repository already cloned. Skipping clone step."
    fi

    Log-SubStep "Replace variables in the configuration file (variables.cfg)."
    if [ ! -f "$config_file" ]; then
        Log-Error "Configuration file $config_file not found. Exiting."
        return 1
    fi

    sed -i "s/^ENVIRONMENT=\".*\"/ENVIRONMENT=\"$NETWORK\"/" "$config_file"
    sed -i "s|^CUSTOM_HOME=.*|CUSTOM_HOME=\"$HOME\"|" "$config_file"
    sed -i "s/^CUSTOM_USER=.*$/CUSTOM_USER=\"$USERNAME\"/" "$config_file"

}

# Function that install the observing squad and press enter to all the questions
ObsSquad_Install() {
    Log-Step "Install Observing Squad"

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

    # Link Go to the PATH
    Log-SubStep "Link installed Go to the PATH"
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
    export PATH=$PATH:/usr/local/go/bin
}

# Function to copy the external.toml and prefs.toml files to the different node folders
ObsSquad_Copy_Configuration() {
    Log-Step "Overwrite node configurations into ~/elrond-nodes/node-[0,1,2,3]/config"

    # Define the source directory for configuration files
    local config_source_dir="$HOME/mvx-api-deployer/configurationFiles/services/0-observingSquad/elrond-nodes"

    # Verify if the source directory exists
    if [ ! -d "$config_source_dir" ]; then
        Log-Error "Source configuration directory $config_source_dir does not exist."
        return 1
    fi

    # Define the destination directory for node configurations
    local node_base_dir="$HOME/elrond-nodes"

    # Iterate through each node directory
    for node_index in {0..3}; do
        local node_dir="$node_base_dir/node-$node_index/config"
        local external_file_source="$config_source_dir/node-$node_index/config/external.toml"
        local prefs_file_source="$config_source_dir/node-$node_index/config/prefs.toml"

        # Check if the node directory exists
        if [ ! -d "$node_dir" ]; then
            Log-Warning "Node directory $node_dir does not exist. Skipping."
            continue
        fi

        # Overwrite external.toml
        if [ -f "$external_file_source" ]; then
            cp "$external_file_source" "$node_dir/"
            Log-SubStep "Copied external.toml to $node_dir"
        else
            Log-Warning "external.toml not found for node-$node_index. Skipping."
        fi

        # Overwrite prefs.toml
        if [ -f "$prefs_file_source" ]; then
            cp "$prefs_file_source" "$node_dir/"
            Log-SubStep "Copied prefs.toml to $node_dir"
        else
            Log-Warning "prefs.toml not found for node-$node_index. Skipping."
        fi
    done

    Log "Node configurations successfully updated."
}
