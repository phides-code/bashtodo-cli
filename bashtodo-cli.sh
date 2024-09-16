#!/bin/bash

SCRIPT_DIR="$(dirname "$0")"

source "$SCRIPT_DIR/list.sh"
source "$SCRIPT_DIR/create.sh"
source "$SCRIPT_DIR/mark-complete.sh"
source "$SCRIPT_DIR/edit.sh"
source "$SCRIPT_DIR/delete.sh"
source "$SCRIPT_DIR/.private"

if [ -z "$api_url" ]; then
    echo "Error: api_url is not set in the .private file."
    exit 1
fi

if [ -z "$api_key" ]; then
    echo "Error: api_key is not set in the .private file."
    exit 1
fi

quit_script() {
    echo "Quitting..."
    exit 0
}
 
show_menu() {
    echo -n "(P)ending, (C)ompleted, (A)ll, (N)ew, (M)ark Complete, (E)dit, (D)elete, (Q)uit. Selection: "
    read -r selection
    case "${selection^^}" in
        P) list_items "pending" ;;
        C) list_items "completed" ;;
        A) list_items ;;
        N) create_item ;;
        M) mark_item_complete ;;
        E) edit_item ;;
        D) delete_item ;;
        Q) quit_script ;;
        *) echo ;;
    esac
}

while true; do
    show_menu
done
