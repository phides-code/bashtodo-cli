#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

list_items() {
    # Evaluate if an argument got passed
    task_status="$1"

    if [[ "$task_status" == "COMPLETED" || "$task_status" == "PENDING" ]]; then
        json_output=$(aws dynamodb scan --table-name BashtodoTasks \
                                        --filter-expression "taskStatus = :ts" \
                                        --expression-attribute-values "{ \":ts\": {\"S\": \"$task_status\"} }")
    else
        json_output=$(aws dynamodb scan --table-name BashtodoTasks)
    fi

    # Parse and display the tasks ordered by createdOn with color coding based on taskStatus
    echo "$json_output" | jq -r '
        .Items
        | sort_by(.createdOn.N | tonumber)
        | to_entries[]
        | [.key + 1, .value.content.S, .value.taskStatus.S]
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
