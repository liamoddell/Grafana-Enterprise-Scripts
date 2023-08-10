import requests
import argparse
import json

def get_usernames(api_url, admin_credentials, headers):
    try:
        response = requests.get(api_url, auth=admin_credentials, headers=headers)
        response.raise_for_status()
        users = response.json()

        return [{"loginOrEmail": user['login'], "role": user['role']} for user in users]
    except requests.exceptions.RequestException as e:
        print(f"Error while communicating with Grafana API: {str(e)}")
        return []

def save_usernames_to_file(usernames_roles, output_filename):
    with open(output_filename, "w") as file:
        json.dump(usernames_roles, file, indent=4)
    print(f"Usernames and roles saved to {output_filename}")

def main():
    parser = argparse.ArgumentParser(description="Retrieve usernames and roles from Grafana organization.")
    parser.add_argument("--output", required=True, help="Path to the output JSON file (without .json extension)")
    args = parser.parse_args()

    api_url = "http://admin:admin@<your_grafana_instance>/api/org/users"
    admin_credentials = ("admin", "admin")
    headers = {"Content-Type": "application/json"}

    usernames_roles = get_usernames(api_url, admin_credentials, headers)

    if usernames_roles:
        output_filename = args.output + ".json"
        save_usernames_to_file(usernames_roles, output_filename)
    else:
        print("No usernames and roles found.")

if __name__ == "__main__":
    main()