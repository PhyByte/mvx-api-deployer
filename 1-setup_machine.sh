#!/bin/bash

# Load variables from env.config
source ./env.config
source functions/server.sh
source functions/log-tools.sh

# Default username fallback in case USERNAME is not set
USERNAME="${USERNAME:-mvx-api}"

Log-Step "Upgrade the system's packages"
Upgrade_System

Log-Step "Install Docker and Docker Compose"
Install_Docker_With_Compose

Log-Step "Create a new user with Docker access"
Create_New_User

Log-Step "Transfer the ressources to the newly created user"
Transfer_Ressources


Log-Step "Login to the new user: ${USERNAME}"
sudo su - $USERNAME
