import sys
import requests
import json

def main():
    if len(sys.argv) != 5:
        print("Usage: python script.py <GRAFANA_INSTANCE> <API_KEY> <TARGET_ORG_ID> <INPUT_JSON>")
        return

    grafana_instance = sys.argv[1]
    api_key = sys.argv[2]
    target_org_id = sys.argv[3]
    input_json_filename = sys.argv[4]

    if not grafana_instance:
        print("Error: Please provide a valid Grafana instance URL starting with 'http' or 'https'.")
        return

    if not api_key:
        print("Error: Please provide a valid API key.")
        return

    if not target_org_id.isdigit():
        print("Error: Please provide a valid organization ID as a numerical value.")
        return

    if not input_json_filename:
        print("Error: Please provide the path to your JSON datasource file.")
        return

    with open(input_json_filename, 'r') as json_file:
        datasources = json.load(json_file)

    headers = {
        'Authorization': f'Bearer {api_key}',
        'Content-Type': 'application/json',
    }

    target_datasources_endpoint = f"{grafana_instance}/api/datasources"

    for datasource in datasources:
        datasource['orgId'] = target_org_id  # Set target organization ID
        response = requests.post(target_datasources_endpoint, headers=headers, json=datasource)

        if response.status_code == 200:
            print(f"Datasource '{datasource['name']}' added to organization '{target_org_id}'.")
        else:
            print(f"Failed to add datasource '{datasource['name']}' to organization '{target_org_id}'. "
                  f"Status code: {response.status_code}")

if __name__ == "__main__":
    main()
