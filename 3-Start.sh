#!/bin/bash

# Load variables from configuration File
source config.cfg

# Import scripts for the different scripts
source scripts/0-common.sh

Log-Step "Start Observing Squad"


# Prepare the Observing Squad environment
ObsSquad_Prepare_Environment

# Install the Observing Squad
ObsSquad_Install

# Activate Indexer configuration for nodes
ObsSquad_Activate_Indexer

# ---------------------------------------------------------
#        Install MultiversX Indexer
# ---------------------------------------------------------
Log-Step "Install MultiversX Indexer"
EsIndexer_Install


# ---------------------------------------------------------
#        Install MultiversX API
# ---------------------------------------------------------
Log-Step "Install MultiversX API"
MxApi_Install
