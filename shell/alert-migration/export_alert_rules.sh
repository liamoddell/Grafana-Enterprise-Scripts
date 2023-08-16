#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <GRAFANA_URL> <GRAFANA_TOKEN> <OUTPUT_DIR>"
    exit 1
fi

GRAFANA_URL="$1"
GRAFANA_TOKEN="$2"
OUTPUT_DIR="$3"
ALERTS_JSON_PATH="${OUTPUT_DIR}/alerts.json"

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Fetch alert rules using the provided API key and save to JSON file
curl -X GET \
  -H "Authorization: Bearer ${GRAFANA_TOKEN}" \
  "${GRAFANA_URL}/api/ruler/grafana/api/v1/rules" | jq > "${ALERTS_JSON_PATH}"

echo "Alerts fetched and saved to ${ALERTS_JSON_PATH}"