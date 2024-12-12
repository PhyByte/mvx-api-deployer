ObsSquad_Prepare_Environment() {

    # Step 1: Clone the MultiversX chain scripts repository
    Log-Step "Clone the MultiversX chain scripts repository"
    cd
    git clone https://github.com/multiversx/mx-chain-scripts.git
    cd mx-chain-scripts

    # Step 2: Modify variables.cfg
    CONFIG_FILE="./config/variables.cfg"
    Log-Step "Update variables.cfg with custom values"

    # Replace ENVIRONMENT with the NETWORK variable
    Log-SubStep "Set ENVIRONMENT to $NETWORK"
    sed -i "s/^ENVIRONMENT=\".*\"/ENVIRONMENT=\"$NETWORK\"/" "$CONFIG_FILE"

    # Replace CUSTOM_HOME with the appropriate home path
    CUSTOM_HOME="/home/$USERNAME"
    Log-SubStep "Set CUSTOM_HOME to $CUSTOM_HOME"
    sed -i "s|^CUSTOM_HOME=.*|CUSTOM_HOME=\"$CUSTOM_HOME\"|" "$CONFIG_FILE"

    # Replace CUSTOM_USER with the USERNAME variable
    Log-SubStep "Set CUSTOM_USER to $USERNAME"
    sed -i "s/^CUSTOM_USER=.*$/CUSTOM_USER=\"$USERNAME\"/" "$CONFIG_FILE"

    # Verify changes
    Log-Step "Verify updated variables.cfg"
    grep -E "ENVIRONMENT|CUSTOM_HOME|CUSTOM_USER" "$CONFIG_FILE"

}

# Function that install the observing squad and press enter to all the questions
ObsSquad_Install() {
    cd ~/mx-chain-scripts
    yes "" | ./script.sh observing_squad
}

# Function that copy the external.toml file to the different node folders
ObsSquad_Activate_Indexer() {
    cd 
    # Replace external node configuration files for activate the indexer
    cp ~/mvx-api-deployer/configurationFiles/external.toml ~/elrond-nodes/node-0/config/external.toml
    cp ~/mvx-api-deployer/configurationFiles/external.toml ~/elrond-nodes/node-1/config/external.toml
    cp ~/mvx-api-deployer/configurationFiles/external.toml ~/elrond-nodes/node-2/config/external.toml
    cp ~/mvx-api-deployer/configurationFiles/external.toml ~/elrond-nodes/node-3/config/external.toml

}

