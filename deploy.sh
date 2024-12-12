#!/bin/bash

# Load variables from configuration File
source config.cfg

# Import scripts for the different steps
source steps/0-common.sh
source steps/1-prepare-server.sh
source steps/2-observing-squad.sh

# ---------------------------------------------------------
#  Step 0: Check Configuration & Machine Specifications
# ---------------------------------------------------------
Verify_Configuration
# ---------------------------------------------------------
#  Step 1: Install prerequisites & create new User
# ---------------------------------------------------------
Install_Prerequisites_And_Create_User

# ---------------------------------------------------------
# Step 2: Prepare Observing Squad
# ---------------------------------------------------------

ObsSquad_Prepare_Environment
ObsSquad_Install
ObsSquad_Activate_Indexer

# ---------------------------------------------------------
#  Step 3: Prepare Indexer
# ---------------------------------------------------------
