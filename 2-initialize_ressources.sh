#!/bin/bash
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

  # Generate PEM files
  echo "Generating PEM files in $KEYS_FOLDER..."
  mkdir -p "$KEYS_FOLDER"
# Correct the loop to generate shard PEM files
for i in $(seq 0 $((NUM_OBSERVERS - 1))); do
  docker run --rm --mount type=bind,source="$KEYS_FOLDER",destination=/keys --workdir /keys multiversx/chain-keygenerator:latest
  mv "$KEYS_FOLDER/validatorKey.pem" "$KEYS_FOLDER/${PEM_FILES[$i]}"
done

# Explicitly handle the metachain PEM file
docker run --rm --mount type=bind,source="$KEYS_FOLDER",destination=/keys --workdir /keys multiversx/chain-keygenerator:latest
mv "$KEYS_FOLDER/validatorKey.pem" "$KEYS_FOLDER/${PEM_FILES[3]}"  # 3 is the metachain index

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

changeNodesConfig() {
  echo "Changing node configuration for generated container..."

  # Paths
  CONFIG_FILE="$HOME/mx-chain-mainnet-config/external.toml"

  # Check if the file exists
  if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file $CONFIG_FILE not found."
    exit 1
  fi

  # Ensure .env variables are loaded
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/env.config"

  # Modify the required lines within the first 17 lines
  sed -i '' \
      -e "1,17 s/^Enabled\s*=.*/Enabled = true/" \
      -e "1,17 s#^URL\s*=.*#URL = \"$ELASTIC_URL\"#" \
      -e "1,17 s/^UseKibana\s*=.*/UseKibana = true/" \
      -e "1,17 s/^Username\s*=.*/Username = \"$ELASTIC_USERNAME\"/" \
      -e "1,17 s/^Password\s*=.*/Password = \"$ELASTIC_PASSWORD\"/" \
      "$CONFIG_FILE"

  echo "Configuration updated in $CONFIG_FILE:"
  cat "$CONFIG_FILE" | grep -E "Enabled|URL|UseKibana|Username|Password"
}

setup-observing-environment
changeNodesConfig