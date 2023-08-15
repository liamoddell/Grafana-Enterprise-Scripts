import sys
import requests
import json

def main():
    if len(sys.argv) != 5:
        print("Usage: python script.py <GRAFANA_INSTANCE> <API_KEY> <ORG_ID> <OUTPUT_FILENAME>")
        return

    grafana_instance = sys.argv[1]
    api_key = sys.argv[2]
    org_id = sys.argv[3]
    output_filename = sys.argv[4]

    if not grafana_instance:
        print("Error: Please provide a valid Grafana instance URL starting with 'http' or 'https'.")
        return

    if not api_key:
        print("Error: Please provide a valid API key.")
        return

    if not org_id.isdigit():
        print("Error: Please provide a valid organization ID as a numerical value.")
        return

    # Append '.json' extension to the output filename if not already present
    if not output_filename.lower().endswith('.json'):
        output_filename += '.json'

    datasources_endpoint = f"{grafana_instance}/api/datasources"

    headers = {
        'Authorization': f'Bearer {api_key}',
        'Content-Type': 'application/json',
    }

    response = requests.get(datasources_endpoint, headers=headers, params={'orgId': org_id})

    if response.status_code == 200:
        datasources = response.json()

        with open(output_filename, 'w') as outfile:
            json.dump(datasources, outfile, indent=4)
        print(f"Datasources saved to {output_filename}")
    else:
        print(f"Failed to retrieve datasources. Status code: {response.status_code}")

if __name__ == "__main__":
    main()