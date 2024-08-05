#!/bin/bash

SCRIPT_DIR="$(dirname "$0")"

source "$SCRIPT_DIR/.private"

if [ -z "$api_url" ]; then
    echo "Error: api_url is not set in the .private file."
    exit 1
fi

create_item() {
    echo "Enter Task Content: "
    read -r content

    if [ "$content" != "" ]; then
        post_content "$content"
    fi     
}

post_content() {
    content=$1
    
    api_response=$(curl -s -X POST "$api_url" -H "Content-Type: application/json" -d "{ \"content\": \"$content\" }")

    error_message=$(echo "$api_response" | jq -r '.errorMessage')
    data=$(echo "$api_response" | jq -r '.data')

    if [ "$error_message" == "null" ] && [ "$data" != "null" ]; then
        echo "Task created."
    else
        if [ "$error_message" != "null" ]; then
            echo "Error: $error_message"
        else
            echo "Error reaching API."
        fi
    fi
}
