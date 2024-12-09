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
    echo -e "\n--\n--\n$RED$border$COLOR_OFF"
    echo -e "$RED$step_text$COLOR_OFF"
    echo -e "$RED$border$COLOR_OFF\n--\n--"

    # Increment step number and reset sub-step number
    let STEP_NUM=(${STEP_NUM} + 1)
    let SUB_STEP_NUM=1
}

Log-SubStep() {
    # Construct the sub-step text with numbering
    local sub_step_text="--- $SUB_STEP_NUM/   $1"

    # Print the formatted sub-step
    echo -e "\n--\n$GREEN$sub_step_text$COLOR_OFF\n--"

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
