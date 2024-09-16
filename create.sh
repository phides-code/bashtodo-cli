#!/bin/bash

SCRIPT_DIR="$(dirname "$0")"

source "$SCRIPT_DIR/.private"

create_item() {
    echo "Enter Task Content: "
    read -r content

    if [ "$content" != "" ]; then
        post_content "$content"
    fi     
}

post_content() {
    content=$1
    
    # shellcheck disable=SC2154
    api_response=$(curl -s -X POST -H "x-api-key: ""$api_key""" "$api_url" -H "Content-Type: application/json" -d "{ \"content\": \"$content\" }")

    error_message=$(echo "$api_response" | jq -r '.errorMessage')
    data=$(echo "$api_response" | jq -r '.data')

    if [ "$error_message" == "null" ] && [ "$data" != "null" ]; then
        echo "Task created."
    else
        if [ "$error_message" != "null" ] && [ "$error_message" != "" ]; then
            echo "Error: $error_message"
        else
            echo "Error reaching API."
        fi
    fi
}
