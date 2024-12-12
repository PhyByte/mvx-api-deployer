ObsSquad_Start() {
   Log-Step "Start Observing Squad"
   $HOME/mx-chain-scripts/scripts start_all
}

ObsSquad_Stop() {
   Log-Step "Stop Observing Squad"
   $HOME/mx-chain-scripts/scripts stop_all
}

EsIndexer_Start() {
   Log-Step "Start ElasticSearch Indexer"

   local service_name="elasticindexer"

   # Start the systemd service
   sudo systemctl start "$service_name" || {
      Log-Error "Failed to start ElasticSearch Indexer service. Check logs with 'journalctl -u $service_name'."
      return 1
   }

   # Check the status of the service
   sudo systemctl status "$service_name" --no-pager || {
      Log-Error "ElasticSearch Indexer service is not running as expected. Check logs with 'journalctl -u $service_name'."
      return 1
   }

   Log "ElasticSearch Indexer service started successfully."
}

EsIndexer_Stop() {
   Log-Step "Stop ElasticSearch Indexer"

   local service_name="elasticindexer"

   # Stop the systemd service
   sudo systemctl stop "$service_name" || {
      Log-Error "Failed to stop ElasticSearch Indexer service."
      return 1
   }

   # Verify the service is stopped
   sudo systemctl status "$service_name" --no-pager | grep "inactive (dead)" &>/dev/null
   if [ $? -eq 0 ]; then
      Log "ElasticSearch Indexer service stopped successfully."
   else
      Log-Error "ElasticSearch Indexer service is still running. Please check manually."
      return 1
   fi
}
EsKibana_Start() {
   Log-Step "Start ElasticSearch and Kibana using Docker Compose"

   local compose_file="$HOME/mx-chain-es-indexer-go/docker-compose.yml"

   # Verify the Docker Compose file exists
   if [ ! -f "$compose_file" ]; then
      Log-Error "Docker Compose file $compose_file not found. Ensure the repository was cloned and configured properly."
      return 1
   fi

   # Navigate to the repository directory
   cd "$(dirname "$compose_file")" || {
      Log-Error "Failed to navigate to the directory containing $compose_file."
      return 1
   }

   # Start services with Docker Compose
   docker-compose up -d || {
      Log-Error "Failed to start ElasticSearch and Kibana services. Check Docker Compose logs for details."
      return 1
   }

   Log "ElasticSearch and Kibana services started successfully."
}

EsKibana_Stop() {
   Log-Step "Stop ElasticSearch and Kibana using Docker Compose"

   local compose_file="$HOME/mx-chain-es-indexer-go/docker-compose.yml"

   # Verify the Docker Compose file exists
   if [ ! -f "$compose_file" ]; then
      Log-Error "Docker Compose file $compose_file not found. Ensure the repository was cloned and configured properly."
      return 1
   fi

   # Navigate to the repository directory
   cd "$(dirname "$compose_file")" || {
      Log-Error "Failed to navigate to the directory containing $compose_file."
      return 1
   }

   # Stop services with Docker Compose
   docker-compose down || {
      Log-Error "Failed to stop ElasticSearch and Kibana services. Check Docker Compose logs for details."
      return 1
   }

   Log "ElasticSearch and Kibana services stopped successfully."
}

MxApi_Start() {
   Log-Step "Start MultiversX API Service"

   local repo_dir="$HOME/mx-api-service"

   # Verify the repository exists
   if [ ! -d "$repo_dir" ]; then
      Log-Error "Repository directory $repo_dir does not exist. Ensure the repository was installed correctly."
      return 1
   fi

   # Navigate to the repository directory
   cd "$repo_dir" || {
      Log-Error "Failed to navigate to $repo_dir. Ensure the directory exists."
      return 1
   }

   # Start the API in production mode
   Log-SubStep "Start the API in production mode"
   npm run start:prod &

   # Capture the process ID and store it for later use
   local pid=$!
   echo "$pid" >"$repo_dir/mx-api.pid"
   Log "MultiversX API started successfully with PID $pid."
}

MxApi_Stop() {
   Log-Step "Stop MultiversX API Service"

   local repo_dir="$HOME/mx-api-service"
   local pid_file="$repo_dir/mx-api.pid"

   # Check if the PID file exists
   if [ ! -f "$pid_file" ]; then
      Log-Warning "PID file not found. The API might not be running."
      return 1
   fi

   # Read the PID and stop the process
   local pid
   pid=$(cat "$pid_file")
   if kill -9 "$pid" &>/dev/null; then
      Log "MultiversX API stopped successfully."
      rm -f "$pid_file" # Clean up the PID file
   else
      Log-Error "Failed to stop the MultiversX API. The process may not be running."
      return 1
   fi
}
