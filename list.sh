#!/bin/bash

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

    # Parse and display the tasks ordered by createdOn
    echo "$json_output" | jq -r '
        .Items
        | sort_by(.createdOn.N | tonumber)
        | to_entries[]
        | "\(.key + 1)) \(.value.content.S)"
    '
}
