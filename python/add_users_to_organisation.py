import requests
import argparse
import json

def list_organizations(api_url, admin_credentials, headers):
    try:
        response = requests.get(api_url, auth=admin_credentials, headers=headers)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"Error listing organizations. Error: {str(e)}")
        return []

def add_users_to_organization(users_roles, organization_id, admin_credentials, headers):
    organization_url = f"http://<your_grafana_instance>/api/orgs/{organization_id}/users"
    for user_info in users_roles:
        user = user_info["loginOrEmail"]
        role = user_info["role"]
        user_payload = {"loginOrEmail": user, "role": role}
        try:
            add_response = requests.post(organization_url, auth=admin_credentials, headers=headers, json=user_payload)
            if add_response.status_code == 409:
                print(f"User {user} is already a member of the organization.")
            elif add_response.status_code == 200:
                print(f"User {user} added to the organization with role '{role}'.")
            else:
                add_response.raise_for_status()
        except requests.exceptions.RequestException as e:
            print(f"Failed to add user {user}. Error: {str(e)}")

def main():
    parser = argparse.ArgumentParser(description="Add users to a Grafana organization.")
    parser.add_argument("--file", required=True, help="Path to the JSON input file")
    args = parser.parse_args()

    try:
        with open(args.file, "r") as file:
            usernames_roles = json.load(file)

        if not usernames_roles:
            print("No usernames and roles found in the file.")
            return

        api_url = "http://admin:admin@<your_grafana_instance>/api/orgs"
        admin_credentials = ("admin", "admin")
        headers = {"Content-Type": "application/json"}

        organizations = list_organizations(api_url, admin_credentials, headers)

        if not organizations:
            print("No organizations found.")
            return

        print("Available Organizations:")
        for idx, org in enumerate(organizations, start=1):
            print(f"{idx}. ID: {org['id']}, Name: {org['name']}")

        target_idx = int(input("Choose target organization (number): ")) - 1

        if not (0 <= target_idx < len(organizations)):
            print("Invalid organization selection.")
            return

        target_organization = organizations[target_idx]

        print(f"Target Organization: {target_organization['name']} (ID: {target_organization['id']})")

        add_users_to_organization(usernames_roles, target_organization['id'], admin_credentials, headers)

        print("User migration completed. 🌌 The Force is strong with this organization! May the data be with you. 🚀")
    except FileNotFoundError:
        print("Input file not found. Please check the file path and try again.")
    except requests.exceptions.RequestException as e:
        print(f"Error while communicating with Grafana API: {str(e)}")

if __name__ == "__main__":
    main()