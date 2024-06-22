#!/bin/bash

# Function to display script usage
function display_usage {
    echo -e "Usage: $0 [-f <file>] [-d <dictionaryfile>]"
    echo -e "Options:"
    echo -e "  -f, --file <file>             Specify the file to crack (required)"
    echo -e "  -d, --dictionary <dictionaryfile>   Specify the dictionary file containing passwords (required)"
    echo -e "  -h, --help                    Display script usage"
    exit 1
}

# Function to display the loading animation
function display_loading {
    local pid=$1
    local delay=0.1
    local spin='-\|/'
    while [ -d /proc/"$pid" ]; do
        printf "[%c] Searching for password...\r" "${spin:i++%${#spin}:1}"
        sleep "$delay"
    done
    printf "\n"
}

# Function to display the script banner
function display_banner {
    echo -e "\e[1;33m--------------------------------------------"
    echo -e "    \e[1;35mFile Brute Force Password Cracker\e[1;33m     "
    echo -e "--------------------------------------------"
    echo -e "             \e[1;36mCreated by MrShadow\e[1;33m         "
    echo -e "--------------------------------------------\e[0m"
}

# Initialize variables with default values
file=""
dictionary=""

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -f|--file)
            file="$2"
            shift
            shift
            ;;
        -d|--dictionary)
            dictionary="$2"
            shift
            shift
            ;;
        -h|--help)
            display_usage
            ;;
        *)
            display_usage
            ;;
    esac
done

# Check if required arguments are provided
if [[ -z $file || -z $dictionary ]]; then
    display_usage
fi

# Check if the file exists
if [ ! -f "$file" ]; then
    echo -e "\e[1;31mError: File '$file' not found.\e[0m"
    exit 1
fi

# Check the file extension
extension="${file##*.}"

case "$extension" in
    zip|ZIP)
        extract_command="unzip -o -P \$password $file >/dev/null 2>&1"
        ;;
    rar|RAR)
        extract_command="unrar x -p\$password $file >/dev/null 2>&1"
        ;;
    pdf|PDF)
        extract_command="pdftk $file input_pw \$password output /dev/null 2>&1"
        ;;
    *)
        echo -e "\e[1;31mError: Unsupported file format.\e[0m"
        exit 1
        ;;
esac

# Display the script banner
display_banner

# Perform the brute-force attack
total_passwords=$(wc -l < "$dictionary")
current_attempt=0

# Start loading animation in the background
display_loading $$ &

while read -r password; do
    current_attempt=$((current_attempt + 1))
    if eval "$extract_command"; then
        kill $! >/dev/null 2>&1
        echo -e "\n\e[1;32mPassword found: $password\e
