#!/bin/bash

SCRIPT_DIR="$(dirname "$0")"

source "$SCRIPT_DIR/list.sh"
source "$SCRIPT_DIR/create.sh"
source "$SCRIPT_DIR/edit.sh"
source "$SCRIPT_DIR/delete.sh"

quit_script() {
    echo "Quitting..."
    exit 0
}
 
show_menu() {
    echo -n "Show (P)ending, Show (C)ompleted, Show (A)ll, Create (N)ew, (E)dit, (D)elete, (Q)uit. Selection: "
    read -r selection
    case "${selection^^}" in
        P) list_items "PENDING" ;;
        C) list_items "COMPLETED" ;;
        A) list_items ;;
        N) create_item ;;
        E) edit_item ;;
        D) delete_item ;;
        Q) quit_script ;;
        *) echo "Invalid selection. Please try again." ;;
    esac
}

while true; do
    show_menu
done
