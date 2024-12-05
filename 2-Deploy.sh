setup-observing-environment() {
  # Configuration
  KEYS_FOLDER="$HOME/mvx-api-deployer/keys"
  SQUAD_FOLDER="$HOME/mvx-api-deployer/ObservingSquad"
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
  for i in $(seq 0 $NUM_OBSERVERS); do
    docker run --rm --mount type=bind,source="$KEYS_FOLDER",destination=/keys --workdir /keys multiversx/chain-keygenerator:latest
    mv "$KEYS_FOLDER"/validatorKey.pem "$KEYS_FOLDER/${PEM_FILES[$i]}"
  done

  # Generate Metachain PEM file
  docker run --rm --mount type=bind,source="$KEYS_FOLDER",destination=/keys --workdir /keys multiversx/chain-keygenerator:latest
  mv "$KEYS_FOLDER"/validatorKey.pem "$KEYS_FOLDER/${PEM_FILES[-1]}"

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


setup-observing-environment