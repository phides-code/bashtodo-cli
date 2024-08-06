#!/bin/bash

SCRIPT_DIR="$(dirname "$0")"

source "$SCRIPT_DIR/.private"

if [ -z "$api_url" ]; then
    echo "Error: api_url is not set in the .private file."
    exit 1
fi

GREEN='\033[0;32m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

delete_item() {
    list_deletable_tasks;

    # Prompt user to enter the task number to delete
    echo -n "Enter the number of the task to delete: "
    read -r task_number

    if [[ "$task_number" -gt 0 && "$task_number" -lt "$array_length + 1" ]]; then
        task_id=${task_ids[$((task_number - 1))]}

        delete_task;
    fi
}

list_deletable_tasks() {
    api_response=$(curl -s "$api_url")

    error_message=$(echo "$api_response" | jq -r '.errorMessage')
    data=$(echo "$api_response" | jq -r '.data')

    if [ "$error_message" == "null" ] && [ "$data" != "null" ]; then
        store_and_display_ids;
    else
        if [ "$error_message" != "null" ]; then
            echo "Error: $error_message"
        else
            echo "Error reaching API."
        fi
    fi
}

store_and_display_ids() {
    # Array to store task IDs
    task_ids=()

    # Process JSON data and store IDs using process substitution
    while IFS=$'\t' read -r index id content status; do
        # Display tasks with color coding
        if [[ "$status" == "PENDING" ]]; then
            echo -e "${BLUE}${index}) ${content}${NC}"
        elif [[ "$status" == "COMPLETED" ]]; then
            echo -e "${GREEN}${index}) ${content}${NC}"
        else
            echo -e "${index}) ${content}"
        fi

        # Store task IDs in the array
        task_ids+=("$id")
    done < <(echo "$data" | jq -r '
        . 
        | sort_by(.createdOn)
        | to_entries[]
        | [.key + 1, .value.id, .value.content, .value.taskStatus]
        | @tsv
    ')

    array_length=${#task_ids[@]}
}

delete_task() {
    api_response=$(curl -s -X DELETE "$api_url"/"$task_id")

    error_message=$(echo "$api_response" | jq -r '.errorMessage')
    data=$(echo "$api_response" | jq -r '.data')

    if [ "$error_message" == "null" ] && [ "$data" != "null" ]; then
        echo "Task deleted."
    else
        if [ "$error_message" != "null" ]; then
            echo "Error: $error_message"
        else
            echo "Error reaching API."
        fi
    fi
}