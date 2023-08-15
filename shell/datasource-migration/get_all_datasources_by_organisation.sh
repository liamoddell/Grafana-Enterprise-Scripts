#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <GRAFANA_INSTANCE> <API_KEY> <OUTPUT_FILENAME>"
    exit 1
fi

GRAFANA_INSTANCE="$1"
API_KEY="$2"
OUTPUT_FILENAME="$3"

# Append '.json' extension to the output filename if not already present
if [[ ! "$OUTPUT_FILENAME" == *.json ]]; then
    OUTPUT_FILENAME="${OUTPUT_FILENAME}.json"
fi

# Set API endpoint
DATASOURCES_ENDPOINT="${GRAFANA_INSTANCE}/api/datasources"

# Get datasources from the API
response=$(curl -s -X GET "$DATASOURCES_ENDPOINT" -H "Authorization: Bearer $API_KEY")

# Save the response to the output JSON file
echo "$response" > "$OUTPUT_FILENAME"
echo "Datasources saved to $OUTPUT_FILENAME"