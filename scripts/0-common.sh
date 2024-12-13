# ---------------------------------------------------------
# Common Utilities and Logging Functions
# ---------------------------------------------------------

# --------- COLORS ---------
# Reset
COLOR_OFF='\033[0m' # Reset text color

# Text Colors
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'

# Logs numbering
TITLE_NUM=1
STEP_NUM=1
SUB_STEP_NUM=1

# --------- LOGGING FUNCTIONS ---------

# Log a title
Log-Title() {
    # Format and print a title
    local title_text="|    $TITLE_NUM/   $1    |"
    local border=$(printf '%*s' "${#title_text}" '' | tr ' ' '-')

    echo -e $PURPLE"\n--\n--\n$border"
    echo -e "$title_text"
    echo -e "$border\n--\n--\n$COLOR_OFF"

    # Increment the title number
    ((TITLE_NUM++))
}

# Log a main step
Log-Step() {
    # Format and print a main step title
    local step_text="|    $TITLE_NUM.$STEP_NUM   $1    |"
    local border=$(printf '%*s' "${#step_text}" '' | tr ' ' '-')

    echo -e $BLUE"\n--\n$border"
    echo -e "$step_text"
    echo -e "$border\n--\n$COLOR_OFF"

    # Increment the step number and reset the sub-step number
    ((STEP_NUM++))
    SUB_STEP_NUM=1
}

# Log a sub-step
Log-SubStep() {
    # Format and print a sub-step title
    local sub_step_text="--- $TITLE_NUM.$STEP_NUM.$SUB_STEP_NUM/   $1"

    echo -e "$CYAN\n--\n$sub_step_text\n--$COLOR_OFF"

    # Increment the sub-step number
    ((SUB_STEP_NUM++))
}

# General log for informational messages
Log() {
    echo -e "\n$BLUE - $1  $COLOR_OFF\n"
}

# Log a warning message
Log-Warning() {
    echo -e "\n${YELLOW} WARNING:  $1 $COLOR_OFF\n"
}

# Log an error message
Log-Error() {
    echo -e "\n${RED} ERROR:    $1 $COLOR_OFF\n"
}

# ---------------------------------------------------------
# Configuration Validation
# ---------------------------------------------------------

# Verify that mandatory variables are set
Verify_Configuration() {
    Log-Step "Validate Configuration"
    # Track if any errors are found
    ERROR_FOUND=false

    # Check USERNAME
    if [ -z "$USERNAME" ]; then
        Log-Error "The USERNAME variable is not set in the configuration file."
        ERROR_FOUND=true
    fi

    # Check NETWORK
    if [ -z "$NETWORK" ]; then
        Log-Error "The NETWORK variable is not set in the configuration file."
        ERROR_FOUND=true
    elif [[ "$NETWORK" != "mainnet" && "$NETWORK" != "devnet" && "$NETWORK" != "testnet" ]]; then
        Log-Error "The NETWORK variable must be one of the following: mainnet, devnet, or testnet."
        ERROR_FOUND=true
    fi

    # Exit if errors are found
    if [ "$ERROR_FOUND" = true ]; then
        Log-Error "Configuration verification failed. Please fix the errors above."
        exit 1
    fi

    Log "Configuration verification completed successfully."
}
