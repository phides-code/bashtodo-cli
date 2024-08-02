#!/bin/bash

# Get the directory of the current script
SCRIPT_DIR="$(dirname "$0")"

# Source all function files relative to the script's directory
source "$SCRIPT_DIR/list.sh"
source "$SCRIPT_DIR/create.sh"
source "$SCRIPT_DIR/edit.sh"
source "$SCRIPT_DIR/delete.sh"

# Function to quit the script
quit_script() {
    echo "Quitting the script."
    exit 0
}

# Main menu function
show_menu() {
    echo "(L)ist, (C)reate, (E)dit, (D)elete, (Q)uit. Selection: "
    read -r selection
    case "${selection^^}" in
        L) list_items ;;
        C) create_item ;;
        E) edit_item ;;
        D) delete_item ;;
        Q) quit_script ;;
        *) echo "Invalid selection. Please try again." ;;
    esac
}

# Main loop
while true; do
    show_menu
done
