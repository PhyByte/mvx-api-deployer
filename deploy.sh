#!/bin/bash

# Load variables from env.config
source ./env.config
source services/0-common.sh
source services/1-prepare_server.sh

# Default username fallback in case USERNAME is not set
USERNAME="${USERNAME:-mvx-api}"

# ---------------------------------------------------------
#  Step 0: Check Configuration & Machine Specifications
# ---------------------------------------------------------

# ---------------------------------------------------------
#  Step 1: Install prerequisites & create new User
# ---------------------------------------------------------
Install_Prerequisites_And_Create_User

# ---------------------------------------------------------
# Step 2: Prepare Observing Squad
# ---------------------------------------------------------

