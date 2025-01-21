# ---------------------------------------------------------
# Observing Squad Installation Functions
# Official Link: https://docs.multiversx.com/integrators/observing-squad
# ---------------------------------------------------------

# --------- PATH DECLARATIONS ---------
REPO_DIR="$HOME/mx-chain-scripts"
CONFIG_FILE="$REPO_DIR/config/variables.cfg"
SCRIPT_FILE="$REPO_DIR/script.sh"
CONFIG_SOURCE_DIR="$HOME/mvx-api-deployer/configurationFiles/services/0-observingSquad/elrond-nodes"
NODE_BASE_DIR="$HOME/elrond-nodes"

# --------- FUNCTIONS ---------

# Prepare the Observing Squad Environment
ObsSquad_Prepare_Environment() {
    Log-Step "Preparing the Observing Squad environment"

    # Clone the repository if not already present
    if [ ! -d "$REPO_DIR" ]; then
        Log-SubStep "Cloning the MultiversX chain scripts repository"
        git clone https://github.com/multiversx/mx-chain-scripts.git "$REPO_DIR"
        Log "Repository cloned successfully into $REPO_DIR"
    else
        Log "Repository already exists in $REPO_DIR. Skipping cloning step."
    fi

    # Replace variables in the configuration file
    Log-SubStep "Updating configuration variables in $CONFIG_FILE"
    if [ ! -f "$CONFIG_FILE" ]; then
        Log-Error "Configuration file $CONFIG_FILE not found. Unable to proceed."
        return 1
    fi

    sed -i "s/^ENVIRONMENT=\".*\"/ENVIRONMENT=\"$NETWORK\"/" "$CONFIG_FILE"
    sed -i "s|^CUSTOM_HOME=.*|CUSTOM_HOME=\"$HOME\"|" "$CONFIG_FILE"
    sed -i "s/^CUSTOM_USER=.*$/CUSTOM_USER=\"$USERNAME\"/" "$CONFIG_FILE"
    Log "Configuration variables updated successfully."
}

# Install the Observing Squad and approve all prompts automatically
ObsSquad_Install() {
    Log-Step "Installing the Observing Squad"

    # Ensure the script directory exists
    if [ ! -d "$REPO_DIR" ]; then
        Log-Error "Directory $REPO_DIR does not exist. Please prepare the environment first."
        return 1
    fi

    # Ensure the script file exists
    if [ ! -f "$SCRIPT_FILE" ]; then
        Log-Error "Script file $SCRIPT_FILE not found in $REPO_DIR."
        return 1
    fi

    # Run the script and approve all prompts
    Log-SubStep "Running the Observing Squad installation script"
    yes "" | "$SCRIPT_FILE" observing_squad
    if [ $? -eq 0 ]; then
        Log "Observing Squad installation completed successfully."
    else
        Log-Error "Observing Squad installation encountered errors."
        return 1
    fi

    # Link Go to the PATH
    Log-SubStep "Adding Go binary to PATH"
    echo 'export PATH=$PATH:/usr/local/go/bin' >>~/.bashrc
    export PATH=$PATH:/usr/local/go/bin
    Log "Go binary successfully linked to PATH."
}

# Copy the external.toml and prefs.toml files to the appropriate node directories
ObsSquad_Copy_Configuration() {
    Log-Step "Updating node configurations in $NODE_BASE_DIR"

    # Verify if the source directory exists
    if [ ! -d "$CONFIG_SOURCE_DIR" ]; then
        Log-Error "Source directory for configurations not found: $CONFIG_SOURCE_DIR"
        return 1
    fi

    # Iterate through each node directory
    for node_index in {0..3}; do
        local node_dir="$NODE_BASE_DIR/node-$node_index/config"
        local external_file_source="$CONFIG_SOURCE_DIR/node-$node_index/external.toml"
        local prefs_file_source="$CONFIG_SOURCE_DIR/node-$node_index/prefs.toml"

        # Check if the node directory exists
        if [ ! -d "$node_dir" ]; then
            Log-Warning "Node directory not found: $node_dir. Skipping node-$node_index."
            continue
        fi

        # Overwrite external.toml
        if [ -f "$external_file_source" ]; then
            cp "$external_file_source" "$node_dir/"
            Log-SubStep "external.toml copied to $node_dir"
        else
            Log-Warning "external.toml missing for node-$node_index in $CONFIG_SOURCE_DIR. Skipping."
        fi

        # Overwrite prefs.toml
        if [ -f "$prefs_file_source" ]; then
            cp "$prefs_file_source" "$node_dir/"
            Log-SubStep "prefs.toml copied to $node_dir"
        else
            Log-Warning "prefs.toml missing for node-$node_index in $CONFIG_SOURCE_DIR. Skipping."
        fi
    done

    Log "Node configurations updated for all available nodes."
}
