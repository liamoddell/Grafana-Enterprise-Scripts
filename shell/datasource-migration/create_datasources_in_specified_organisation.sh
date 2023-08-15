#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <GRAFANA_INSTANCE> <API_KEY> <INPUT_JSON>"
    exit 1
fi

GRAFANA_INSTANCE="$1"
API_KEY="$2"
INPUT_JSON="$3"

# Set API endpoint
TARGET_DATASOURCES_ENDPOINT="${GRAFANA_INSTANCE}/api/datasources"

# Read JSON file
DATA=$(cat "$INPUT_JSON")

# Loop through each datasource object in the JSON and post to the target endpoint
for datasource in $(echo "$DATA" | jq -c '.[]'); do
    datasource_name=$(echo "$datasource" | jq -r '.name')
    
    # Check if the datasource already exists in the target org
    response=$(curl -s -o /dev/null -w "%{http_code}" -X GET "$TARGET_DATASOURCES_ENDPOINT/name/$datasource_name" -H "Authorization: Bearer $API_KEY")
    
    if [ "$response" == "200" ]; then
        echo "Datasource '$datasource_name' already exists in organisation. Skipping."
    else
        curl_response=$(curl -s -X POST "$TARGET_DATASOURCES_ENDPOINT" -H "Authorization: Bearer $API_KEY" -H "Content-Type: application/json" -d "$datasource")
        if [[ $curl_response == *"Datasource added"* ]]; then
            echo "Datasource '$datasource_name' added to organisation."
        else
            echo "Failed to add datasource '$datasource_name' to organisation."
            echo "$curl_response"
        fi
    fi
done
