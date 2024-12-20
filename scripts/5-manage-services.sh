#!/bin/bash

# ---------------------------------------------------------
# MultiversX API Deployer - Start and Stop Services
# ---------------------------------------------------------

# --------- START ALL SERVICES ---------

Start_All_Services() {
   Log-Step "Start All Services"

   ObsSquad_Start || Log-Warning "Observing Squad failed to start."
   EsIndexer_Start || Log-Warning "ElasticSearch Indexer failed to start."
   EsKibana_Start || Log-Warning "ElasticSearch and Kibana failed to start."
   MxApi_Start || Log-Warning "MultiversX API failed to start."

   Log "All services start commands executed. Verify individual service statuses."
}

# --------- STOP ALL SERVICES ---------

Stop_All_Services() {
   Log-Step "Stop All Services"

   MxApi_Stop || Log-Warning "MultiversX API failed to stop."
   EsKibana_Stop || Log-Warning "ElasticSearch and Kibana failed to stop."
   EsIndexer_Stop || Log-Warning "ElasticSearch Indexer failed to stop."
   ObsSquad_Stop || Log-Warning "Observing Squad failed to stop."

   Log "All services stop commands executed. Verify individual service statuses."
}

# --------- CHECK STATUS OF ALL SERVICES ---------

Check_All_Status() {
   Log-Step "Check Status of All Services"

   Log-SubStep "Checking Observing Squad Status"
   if pgrep -f "start_all" &>/dev/null; then
      Log "Observing Squad is running."
   else
      Log-Warning "Observing Squad is not running."
   fi

   Log-SubStep "Checking ElasticSearch Indexer Status"
   if systemctl is-active --quiet elasticindexer; then
      Log "ElasticSearch Indexer service is running."
   else
      Log-Warning "ElasticSearch Indexer service is not running."
   fi

   Log-SubStep "Checking ElasticSearch and Kibana Status"
   if docker ps | grep -q 'kibana'; then
      Log "ElasticSearch and Kibana services are running."
   else
      Log-Warning "ElasticSearch and Kibana services are not running."
   fi

   Log-SubStep "Checking MultiversX API Status"
   local api_pid_file="$HOME/mx-api-service/mx-api.pid"
   if [ -f "$api_pid_file" ]; then
      local api_pid
      api_pid=$(cat "$api_pid_file")
      if ps -p "$api_pid" &>/dev/null; then
         Log "MultiversX API is running (PID: $api_pid)."
      else
         Log-Warning "MultiversX API is not running, but PID file exists."
      fi
   else
      Log-Warning "MultiversX API PID file not found. The service may not be running."
   fi

   Log "Service status check completed."
}

# --------- OBSERVING SQUAD FUNCTIONS ---------

# Start the Observing Squad
ObsSquad_Start() {
   Log-Step "Start Observing Squad"

   local script_path="$HOME/mx-chain-scripts/script.sh"

   # Check if the script exists and is executable
   if [ -x "$script_path" ]; then
      # Run the script with the appropriate argument
      "$script_path" start_all || {
         Log-Error "Failed to start Observing Squad. Check logs for details."
         return 1
      }
      Log "Observing Squad started successfully."
   else
      Log-Error "Script not found or not executable at $script_path."
      return 1
   fi
}

# Stop the Observing Squad
ObsSquad_Stop() {
   Log-Step "Stop Observing Squad"

   local script_path="$HOME/mx-chain-scripts/script.sh"

   if [ -x "$script_path" ]; then
      "$script_path" stop_all || {
         Log-Error "Failed to stop Observing Squad. Check logs for details."
         return 1
      }
      Log "Observing Squad stopped successfully."
   else
      Log-Error "Stop script not found or not executable at $script_path."
      return 1
   fi
}

# --------- ELASTICSEARCH INDEXER FUNCTIONS ---------

# Start the ElasticSearch Indexer
EsIndexer_Start() {
   Log-Step "Start ElasticSearch Indexer"

   local service_name="elasticindexer"

   sudo systemctl start "$service_name" || {
      Log-Error "Failed to start ElasticSearch Indexer service. Check logs with 'journalctl -u $service_name'."
      return 1
   }

   sudo systemctl status "$service_name" --no-pager || {
      Log-Error "ElasticSearch Indexer service is not running as expected. Check logs with 'journalctl -u $service_name'."
      return 1
   }

   Log "ElasticSearch Indexer service started successfully."
}

# Stop the ElasticSearch Indexer
EsIndexer_Stop() {
   Log-Step "Stop ElasticSearch Indexer"

   local service_name="elasticindexer"

   sudo systemctl stop "$service_name" || {
      Log-Error "Failed to stop ElasticSearch Indexer service."
      return 1
   }

   sudo systemctl status "$service_name" --no-pager | grep "inactive (dead)" &>/dev/null
   if [ $? -eq 0 ]; then
      Log "ElasticSearch Indexer service stopped successfully."
   else
      Log-Error "ElasticSearch Indexer service is still running. Please check manually."
      return 1
   fi
}

# --------- ELASTICSEARCH & KIBANA FUNCTIONS ---------

# Start ElasticSearch and Kibana using Docker Compose
EsKibana_Start() {
   Log-Step "Start ElasticSearch and Kibana using Docker Compose"

   local compose_file="$HOME/mx-chain-es-indexer-go/docker-compose.yml"

   if [ ! -f "$compose_file" ]; then
      Log-Error "Docker Compose file $compose_file not found. Ensure the repository was cloned and configured properly."
      return 1
   fi

   cd "$(dirname "$compose_file")" || {
      Log-Error "Failed to navigate to the directory containing $compose_file."
      return 1
   }

   docker-compose up -d || {
      Log-Error "Failed to start ElasticSearch and Kibana services. Check Docker Compose logs for details."
      return 1
   }

   Log "ElasticSearch and Kibana services started successfully."
}

# Stop ElasticSearch and Kibana using Docker Compose
EsKibana_Stop() {
   Log-Step "Stop ElasticSearch and Kibana using Docker Compose"

   local compose_file="$HOME/mx-chain-es-indexer-go/docker-compose.yml"

   if [ ! -f "$compose_file" ]; then
      Log-Error "Docker Compose file $compose_file not found. Ensure the repository was cloned and configured properly."
      return 1
   fi

   cd "$(dirname "$compose_file")" || {
      Log-Error "Failed to navigate to the directory containing $compose_file."
      return 1
   }

   docker-compose down || {
      Log-Error "Failed to stop ElasticSearch and Kibana services. Check Docker Compose logs for details."
      return 1
   }

   Log "ElasticSearch and Kibana services stopped successfully."
}

# --------- MULTIVERSX API FUNCTIONS ---------

# Start the MultiversX API
MxApi_Start() {
   Log-Step "Start MultiversX API Service"

   local service_name="multiversx-api"

   Log-SubStep "Starting MultiversX API using systemctl"
   sudo systemctl start "$service_name" || {
      Log-Error "Failed to start MultiversX API service. Check logs with 'journalctl -u $service_name'."
      return 1
   }

   sudo systemctl status "$service_name" --no-pager || {
      Log-Error "MultiversX API service is not running as expected. Check logs with 'journalctl -u $service_name'."
      return 1
   }

   Log "MultiversX API service started successfully."
}

# Stop the MultiversX API
MxApi_Stop() {
   Log-Step "Stop MultiversX API Service"

   local service_name="multiversx-api"

   Log-SubStep "Stopping MultiversX API using systemctl"
   sudo systemctl stop "$service_name" || {
      Log-Error "Failed to stop MultiversX API service. Check logs with 'journalctl -u $service_name'."
      return 1
   }

   sudo systemctl status "$service_name" --no-pager | grep "inactive (dead)" &>/dev/null
   if [ $? -eq 0 ]; then
      Log "MultiversX API service stopped successfully."
   else
      Log-Error "MultiversX API service is still running. Please check manually."
      return 1
   fi
}
