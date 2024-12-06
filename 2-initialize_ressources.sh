#!/bin/bash

# Function to set up the observing environment
setup-observing-environment() {
  # Configuration
  KEYS_FOLDER="$HOME/keys"
  SQUAD_FOLDER="$HOME/ObservingSquad"
  NUM_OBSERVERS=3 # Change this if the number of shards changes
  PEM_FILES=("observerKey_0.pem" "observerKey_1.pem" "observerKey_2.pem" "observerKey_metachain.pem")

  # Ensure the necessary tools are installed
  command -v docker >/dev/null 2>&1 || {
    echo >&2 "Docker is required but not installed. Aborting."
    exit 1
  }

  # Create folder structure
  echo "Creating folder structure at $SQUAD_FOLDER..."
  mkdir -p "$SQUAD_FOLDER"/{proxy,node-0,node-1,node-2,node-metachain}/{config,db,logs}

  # Generate PEM files for nodes
  echo "Generating PEM files in $KEYS_FOLDER..."
  mkdir -p "$KEYS_FOLDER"
  for i in $(seq 0 $((NUM_OBSERVERS - 1))); do
    docker run --rm --mount type=bind,source="$KEYS_FOLDER",destination=/keys --workdir /keys multiversx/chain-keygenerator:latest
    mv "$KEYS_FOLDER/validatorKey.pem" "$KEYS_FOLDER/${PEM_FILES[$i]}"
  done

  # Generate PEM file for the metachain
  docker run --rm --mount type=bind,source="$KEYS_FOLDER",destination=/keys --workdir /keys multiversx/chain-keygenerator:latest
  mv "$KEYS_FOLDER/validatorKey.pem" "$KEYS_FOLDER/${PEM_FILES[3]}" # 3 is the metachain index

  # Move PEM files to corresponding config folders
  echo "Copying PEM files to config folders..."
  cp "$KEYS_FOLDER/${PEM_FILES[0]}" "$SQUAD_FOLDER/node-0/config/"
  cp "$KEYS_FOLDER/${PEM_FILES[1]}" "$SQUAD_FOLDER/node-1/config/"
  cp "$KEYS_FOLDER/${PEM_FILES[2]}" "$SQUAD_FOLDER/node-2/config/"
  cp "$KEYS_FOLDER/${PEM_FILES[3]}" "$SQUAD_FOLDER/node-metachain/config/"

  # Set correct ownership
  echo "Setting file permissions..."
  sudo chown -R "$(whoami)" "$SQUAD_FOLDER"

  echo "Folder structure and PEM files setup completed!"
  echo "Your folder structure is ready at $SQUAD_FOLDER."
}

# Function to modify the configuration file
generateDockerImage() {
  echo "Clone official source and modify configuration before to build"
  cd
  git clone https://github.com/multiversx/mx-chain-mainnet-config.git

  # Paths
  CONFIG_FILE="$HOME/mx-chain-mainnet-config/external.toml"
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  ENV_FILE="$SCRIPT_DIR/env.config"

  # Check if the configuration file exists
  if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file $CONFIG_FILE not found."
    exit 1
  fi

  # Check if the environment file exists
  if [ ! -f "$ENV_FILE" ]; then
    echo "Error: Environment file $ENV_FILE not found."
    exit 1
  fi

  # Load environment variables
  source "$ENV_FILE"

  # Update configuration using sed, modifying only the first occurrence of each key
  sed -i \
    -e "0,/^\s*Enabled\s*=.*/s//    Enabled = true/" \
    -e "0,/^\s*URL\s*=.*/s##    URL = \"$ELASTIC_URL\"#" \
    -e "0,/^\s*UseKibana\s*=.*/s//    UseKibana = true/" \
    -e "0,/^\s*Username\s*=.*/s//    Username = \"$ELASTIC_USERNAME\"/" \
    -e "0,/^\s*Password\s*=.*/s//    Password = \"$ELASTIC_PASSWORD\"/" \
    "$CONFIG_FILE"

  echo "Configuration updated in $CONFIG_FILE:"

  cd $HOME/mx-chain-mainnet-config
  # Build the Docker image
  echo "Building Docker image..."
  docker image build . -t chain-mainnet-local -f ./docker/Dockerfile
}

# Execute the setup functions
setup-observing-environment
generateDockerImage
