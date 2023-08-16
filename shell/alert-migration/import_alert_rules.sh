#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <GRAFANA_URL> <GRAFANA_TOKEN> <ALERTS_JSON_PATH>"
    exit 1
fi

GRAFANA_URL="$1"
GRAFANA_TOKEN="$2"
ALERTS_JSON_PATH="$3"

# URL encode function
urlencode() {
  local string="${1}"
  printf '%s' "${string}" | jq -sRr @uri
}

# Function to create a folder
create_folder() {
  FOLDER_TITLE="$1"
  FOLDER_UID="$(uuidgen)"  # Generate a unique UID for the folder
  CREATE_FOLDER_PAYLOAD="{\"uid\": \"$FOLDER_UID\", \"title\": \"$FOLDER_TITLE\"}"
  curl -s -X POST \
    -H "Authorization: Bearer ${GRAFANA_TOKEN}" \
    -H "Content-type: application/json" \
    "${GRAFANA_URL}/api/folders" \
    -d "$CREATE_FOLDER_PAYLOAD"
}

jq -r 'to_entries[] | @base64' "${ALERTS_JSON_PATH}" | while IFS= read -r ENTRY; do
    ALERT_GROUP=$(echo "${ENTRY}" | base64 --decode | jq -r '.key')
    echo
    echo "Rule is part of alert group: ${ALERT_GROUP}"

    # Get the alert objects array for the current group
    ALERT_OBJECTS=$(echo "${ENTRY}" | base64 --decode | jq -c '.value')

    # Loop through each alert object in the current group
    echo "${ALERT_OBJECTS}" | jq -c '.[]' | while IFS= read -r ALERT_OBJECT; do
        FOLDER_NAME=$(echo "${ALERT_OBJECT}" | jq -r '.rules[0].grafana_alert.title')
        ALERT_NAME=$(echo "${ALERT_OBJECT}" | jq -r '.name')

        # Create a copy of the alert object without UID fields & remove UID fields from the alert object
        ALERT_OBJECT_CLEANED=$(echo "${ALERT_OBJECT}" | jq 'del(.rules[].grafana_alert.data[].model.uid) | .rules[].grafana_alert.uid=null')

        echo "Attempting to create folder name: $FOLDER_NAME"

        # Check if folder exists, if not, create it
        FOLDER_RESPONSE=$(curl -s -X GET \
            -H "Authorization: Bearer ${GRAFANA_TOKEN}" \
            "${GRAFANA_URL}/api/folders")
        if echo "$FOLDER_RESPONSE" | grep -q "\"title\":\"${FOLDER_NAME}\""; then
            echo "Folder ${FOLDER_NAME} already exists."
        else
            echo "Creating folder ${FOLDER_NAME}..."
            echo
            create_folder "${FOLDER_NAME}"
        fi

        echo

        echo

        echo "Importing rule $ALERT_NAME"

        ENCODED_FOLDER_NAME=$(urlencode "${FOLDER_NAME}")
        RESPONSE=$(curl -s -X POST \
            -H "Authorization: Bearer ${GRAFANA_TOKEN}" \
            -H "Content-type: application/json" \
            "${GRAFANA_URL}/api/ruler/grafana/api/v1/rules/${ENCODED_FOLDER_NAME}?subtype=cortex" \
            -d "${ALERT_OBJECT_CLEANED}")

        echo

        echo
        echo "Response:"
        echo
        echo "$RESPONSE"
        echo

        echo "<-----------> BREAK <----------->"


        echo
    done
done