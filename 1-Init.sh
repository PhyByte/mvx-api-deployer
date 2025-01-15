#!/bin/bash

# ---------------------------------------------------------
# MultiversX API Deployer - Initialize the Server
# ---------------------------------------------------------

# Load configuration variables
source config.cfg

# Import common functions and server preparation scripts
source scripts/0-common.sh
source scripts/1-server.sh

Log-Title "MultiversX API Deployer - Initialize the Server"
# ---------------------------------------------------------
# Validate Configuration and Machine Specifications
# ---------------------------------------------------------
Verify_Configuration

# ---------------------------------------------------------
# Upgrade System Packages
# ---------------------------------------------------------
Upgrade_System

# ---------------------------------------------------------
# Install Docker and Docker Compose
# ---------------------------------------------------------
Install_Docker

# ---------------------------------------------------------
# Create a New User for Running Services
# ---------------------------------------------------------
Create_User

# ---------------------------------------------------------
# Transfer Repository to the New User
# ---------------------------------------------------------
Transfer_Repository

# ---------------------------------------------------------
# Setup Monitoring
# ---------------------------------------------------------
if [ "$INSTALL_ZABBIX_AGENT" = true ]; then
    Setup_Zabbix_Agent
fi
# ---------------------------------------------------------
# Switch to the New User
# ---------------------------------------------------------
sudo su - $USERNAME

# ---------------------------------------------------------
# Instructions for the User
# ---------------------------------------------------------
Log-Title "Server Initialization Completed"
Log "You are now logged in as $USERNAME. Please proceed with the next script to install the required services by running:"
Log "  cd $HOME/mvx-api-deployer"
Log "  ./2-Install.sh"
