#!/bin/bash

SCRIPT_DIR="$(dirname "$0")"

source "$SCRIPT_DIR/.private"

GREEN='\033[0;32m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

list_items() {
    # Concatenate any argument 
    # we can invoke :
    # list_items "pending" 
    # list_items "completed" 
    # list_items (no arg means all)
    task_status="/$1"

    # shellcheck disable=SC2154
    api_response=$(curl -s -H "x-api-key: ""$api_key""" "$api_url""$task_status")

    error_message=$(echo "$api_response" | jq -r '.errorMessage')
    data=$(echo "$api_response" | jq -r '.data')

    if [ "$error_message" == "null" ] && [ "$data" != "null" ]; then
        parse_and_display "$data"
    else
        if [ "$error_message" != "null" ] && [ "$error_message" != "" ]; then
            echo "Error: $error_message"
        else
            echo "Error reaching API."
        fi
    fi
}

parse_and_display() {
    # Parse and display the tasks ordered by createdOn with color coding based on taskStatus
    data=$1

    echo "$data" | jq -r '
        . 
        | sort_by(.createdOn)
        | to_entries[]
        | [.key + 1, .value.content, .value.taskStatus]
        | @tsv
    ' | while IFS=$'\t' read -r index content status; do
        if [[ "$status" == "PENDING" ]]; then
            echo -e "${BLUE}${index}) ${content}${NC}"
        elif [[ "$status" == "COMPLETED" ]]; then
            echo -e "${GREEN}${index}) ${content}${NC}"
        else
            echo -e "${index}) ${content}"
        fi
    done
}