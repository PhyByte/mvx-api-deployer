#!/bin/bash

# Load variables from configuration File
source config.cfg

# Import scripts for the different scripts
source scripts/0-common.sh
source scripts/2-observing-squad.sh
source scripts/3-es-indexer.sh
source scripts/4-mx-api.sh

# ---------------------------------------------------------
#   Install Observing Squad
# ---------------------------------------------------------
Log-Step "Install Observing Squad"

ObsSquad_Prepare_Environment
ObsSquad_Install
ObsSquad_Activate_Indexer

# ---------------------------------------------------------
#   Install ElasticSearch Indexer
# ---------------------------------------------------------
Log-Step "Install ElasticSearch Indexer"

EsIndexer_Prepare_Environment
EsIndexer_Install_Go
EsIndexer_Build
EsIndexer_Create_Service

# ---------------------------------------------------------
#   Install MultiversX API
# ---------------------------------------------------------
Log-Step "Install MultiversX API"
MxApi_Prepare_Environment
MxApi_Install_Npm
MxApi_Install_Dependencies
MxApi_Initialize