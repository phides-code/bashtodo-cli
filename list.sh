#!/bin/bash

SCRIPT_DIR="$(dirname "$0")"

source "$SCRIPT_DIR/.private"

if [ -z "$api_url" ]; then
    echo "Error: api_url is not set in the .private file."
    exit 1
fi

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

list_items() {
    # Concatenate any argument 
    task_status="/$1"

    api_response=$(curl -s "$api_url""$task_status")

    error_message=$(echo "$api_response" | jq -r '.errorMessage')
    data=$(echo "$api_response" | jq -r '.data')

    if [ "$error_message" == "null" ] && [ "$data" != "null" ]; then
        parse_and_display "$data"
    else
        if [ "$error_message" != "null" ]; then
            echo "Error: $error_message"
        else
            echo "Error reaching API."
        fi
    fi
}

parse_and_display() {
    # Parse and display the tasks ordered by createdOn with color coding based on taskStatus
    json_output=$1

    echo "$json_output" | jq -r '
        . 
        | sort_by(.createdOn)
        | to_entries[]
        | [.key + 1, .value.content, .value.taskStatus]
        | @tsv
    ' | while IFS=$'\t' read -r index content status; do
        if [[ "$status" == "PENDING" ]]; then
            echo -e "${YELLOW}${index}) ${content}${NC}"
        elif [[ "$status" == "COMPLETED" ]]; then
            echo -e "${GREEN}${index}) ${content}${NC}"
        else
            echo -e "${index}) ${content}"
        fi
    done
}