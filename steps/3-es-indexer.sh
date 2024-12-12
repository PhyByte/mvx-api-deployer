EsIndexer_Install() {
    Log-Step "Install ElasticSearch Indexer"

    # Step 1: Clone the repository
    Log-SubStep "Clone the ElasticSearch Indexer repository"
    local repo_url="https://github.com/multiversx/mx-chain-es-indexer-go.git"
    local repo_dir="$HOME/mx-chain-es-indexer-go"

    if [ ! -d "$repo_dir" ]; then
        Log "Cloning repository from $repo_url into $repo_dir"
        git clone "$repo_url" "$repo_dir"
    else
        Log-Warning "Repository already exists at $repo_dir. Skipping clone step."
    fi

    # Step 2: Install Go
    Log-SubStep "Install Go language"
    if ! command -v go &>/dev/null; then
        Log "Installing Go language..."
        sudo apt update && sudo apt install golang-go -y
    else
        Log "Go is already installed. Skipping installation."
    fi

    # Step 3: Navigate to the indexer directory
    Log-SubStep "Navigate to the ElasticSearch Indexer command directory"
    local cmd_dir="$repo_dir/cmd/elasticindexer"
    if [ -d "$cmd_dir" ]; then
        cd "$cmd_dir"
        Log "Navigated to $cmd_dir"
    else
        Log-Error "Directory $cmd_dir does not exist. Ensure the repository was cloned correctly."
        return 1
    fi

    # Step 4: Install the ElasticSearch Indexer
    Log-SubStep "Install the ElasticSearch Indexer using Go"
    go install
    if [ $? -eq 0 ]; then
        Log "ElasticSearch Indexer installed successfully."
    else
        Log-Error "ElasticSearch Indexer installation failed. Check your Go setup."
        return 1
    fi

    # Step 5: Build the executable
    Log-SubStep "Build the ElasticSearch Indexer executable"
    go build -o elasticindexer
    if [ $? -eq 0 ]; then
        Log "ElasticSearch Indexer executable built successfully."
    else
        Log-Error "Failed to build the ElasticSearch Indexer executable."
        return 1
    fi

    Log "ElasticSearch Indexer installation completed."
}
