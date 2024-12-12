# ---------------------------------------------------------
# This file contains common functions and variables that are used in the deployment scripts.
# ---------------------------------------------------------

# ---------------------------------------------------------
# Log Functions
# ---------------------------------------------------------

# --------- COLORS ---------
# Reset
COLOR_OFF='\033[0m' # Text Reset

# Regular Colors
BLACK='\033[0;30m'  # Black
RED='\033[0;31m'    # Red
GREEN='\033[0;32m'  # Green
YELLOW='\033[0;33m' # Yellow
BLUE='\033[0;34m'   # Blue
PURPLE='\033[0;35m' # Purple
CYAN='\033[0;36m'   # Cyan
WHITE='\033[0;37m'  # White

# This function is use to print the main steps of the procedure.
STEP_NUM=1
SUB_STEP_NUM=1

Log-Step() {
    # Construct the title text with numbering
    local step_text="|    $STEP_NUM/   $1    |"
    local line_length=${#step_text}
    local border=$(printf '%*s' "$line_length" '' | tr ' ' '-')

    # Print the formatted step with borders and spacing
    echo -e $RED"\n--\n--\n$RED$border"
    echo -e "$step_text"
    echo -e "$border\n--\n--$COLOR_OFF"

    # Increment step number and reset sub-step number
    let STEP_NUM=(${STEP_NUM} + 1)
    let SUB_STEP_NUM=1
}

Log-SubStep() {
    # Construct the sub-step text with numbering
    local sub_step_text="--- $SUB_STEP_NUM/   $1"

    # Print the formatted sub-step
    echo -e "$GREEN\n--\n$sub_step_text\n--$COLOR_OFF"

    # Increment sub-step number
    let SUB_STEP_NUM=(${SUB_STEP_NUM} + 1)
}
Log() {
    echo -e "\n$BLUE - $1  $COLOR_OFF\n"
}

Log-Warning() {
    echo -e "\n${YELLOW} WARNING:  $1 $COLOR_OFF\n"
}

Log-Error() {
    echo -e "\n${RED} ERROR:    $1 $COLOR_OFF\n"
}

# ---------------------------------------------------------

# Verify if the configuration variables are properly set
Verify_Configuration() {
    # Variable to track errors
    ERROR_FOUND=false

    Log-Step "Verifying configuration variables"

    # Check if the mandatory variables are set before proceeding
    if [ -z "$USERNAME" ]; then
        Log-Error "The USERNAME variable is not set in the configuration file."
        ERROR_FOUND=true
    fi

    if [ -z "$NETWORK" ]; then
        Log-Error "The NETWORK variable is not set in the configuration file."
        ERROR_FOUND=true
    elif [[ "$NETWORK" != "mainnet" && "$NETWORK" != "devnet" && "$NETWORK" != "testnet" ]]; then
        Log-Error "The NETWORK variable must be one of the following: mainnet, devnet, or testnet."
        ERROR_FOUND=true
    fi

    # Check if any error was found
    if [ "$ERROR_FOUND" = true ]; then
        Log-Error "Configuration verification failed. Please fix the errors above."
        exit 1
    fi

    Log "Configuration verification completed successfully."
}
