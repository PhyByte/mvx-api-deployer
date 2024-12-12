#!/bin/bash

# Load variables from configuration File
source config.cfg

# Import scripts for the different steps
source steps/0-common.sh
source steps/1-prepare-server.sh

# ---------------------------------------------------------
#   Check Configuration & Machine Specifications
# ---------------------------------------------------------
Verify_Configuration

# ---------------------------------------------------------
#               Prepare Machine
# ---------------------------------------------------------
#  Step 1: Upgrade the system's packages
Upgrade_System

#  Step 2: Install Docker and Docker Compose
Install_Docker

#  Step 3: Create a new user with Docker access
Create_User

#  Step 4: Login to the new user
sudo su - $USERNAME

# From here, the user will have to run the second script to trigger the installation of the different services.