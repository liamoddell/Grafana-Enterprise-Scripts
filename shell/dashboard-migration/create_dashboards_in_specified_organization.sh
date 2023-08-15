#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <GRAFANA_INSTANCE> <API_KEY> <INPUT_DIR>"
    exit 1
fi

GRAFANA_INSTANCE="$1"
API_KEY="$2"
INPUT_DIR="$3"

# Loop through each dashboard JSON file in the input directory
for dashboard_file in "$INPUT_DIR"/*.json; do
    # Extract the file name without extension
    file_name=$(basename "$dashboard_file" .json)

    # Set dashboard id to null and create a modified JSON file
    jq '.dashboard.id = null' "$dashboard_file" > "create-update.$file_name.json"

    # Send the modified JSON to Grafana API for dashboard import/update
    import_response=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$GRAFANA_INSTANCE/api/dashboards/db" \
                      -H "Authorization: Bearer $API_KEY" \
                      -H "Content-Type: application/json" \
                      -d "@create-update.$file_name.json")

    case "$import_response" in
        200)
            echo "Dashboard from '$dashboard_file' imported successfully."
            ;;
        400)
            echo "Error importing dashboard from '$dashboard_file'. Invalid json or missing/invalid fields."
            ;;
        401)
            echo "Error importing dashboard from '$dashboard_file'. Unauthorized."
            ;;
        403)
            echo "Error importing dashboard from '$dashboard_file'. Access denied."
            ;;
        412)
            echo "Error importing dashboard from '$dashboard_file'. Precondition failed. Does the dashboard exist already?"
            ;;
        *)
            echo "Error importing dashboard from '$dashboard_file'. Response code: $import_response"
            ;;
    esac
done

# Clean up temporary files
rm create-update.*.json