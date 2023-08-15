#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <GRAFANA_INSTANCE> <API_KEY> <OUTPUT_DIR>"
    exit 1
fi

GRAFANA_INSTANCE="$1"
API_KEY="$2"
OUTPUT_DIR="$3"

# Set API endpoint for dashboard retrieval
DASHBOARDS_ENDPOINT="${GRAFANA_INSTANCE}/api/search"

# Retrieve all dashboards
response=$(curl -s -X GET "$DASHBOARDS_ENDPOINT?type=dash-db" -H "Authorization: Bearer $API_KEY")

# Parse the JSON response to get dashboard UIDs
dashboard_uids=($(echo "$response" | jq -r '.[] | .uid'))

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Loop through each dashboard UID
for dashboard_uid in "${dashboard_uids[@]}"; do
    # Retrieve the dashboard JSON
    dashboard_response=$(curl -s -X GET "${GRAFANA_INSTANCE}/api/dashboards/uid/$dashboard_uid" -H "Authorization: Bearer $API_KEY")
    
    # Apply jq command to clean up the JSON structure
    cleaned_dashboard_response=$(echo "$dashboard_response" | jq 'del(.overwrite,.dashboard.version,.meta.created,.meta.createdBy,.meta.updated,.meta.updatedBy,.meta.expires,.meta.version)')
    
    # Save the cleaned dashboard JSON to a file
    output_file="${OUTPUT_DIR}/${dashboard_uid}.json"
    echo "$cleaned_dashboard_response" > "$output_file"
    
    echo "Dashboard with UID '$dashboard_uid' saved to '$output_file'."
done
