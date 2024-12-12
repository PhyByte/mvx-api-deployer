#!/bin/bash

# Load variables from configuration File
source config.cfg

# Import scripts for the different steps
source steps/0-common.sh
source steps/2-observing-squad.sh

# ---------------------------------------------------------
#   Install Observing Squad
# ---------------------------------------------------------
Log-Step "Install Observing Squad"

# Prepare the Observing Squad environment
ObsSquad_Prepare_Environment

# Install the Observing Squad
ObsSquad_Install

# Activate Indexer configuration for nodes
ObsSquad_Activate_Indexer
