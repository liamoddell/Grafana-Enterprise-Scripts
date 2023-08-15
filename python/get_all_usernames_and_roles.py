import requests
import argparse
import json

BASE_URL = "http://admin:admin@<your_grafana_instance>/api/orgs"
ADMIN_CREDENTIALS = ("admin", "admin")
HEADERS = {"Content-Type": "application/json"}

def get_all_organizations():
    try:
        response = requests.get(BASE_URL, auth=ADMIN_CREDENTIALS, headers=HEADERS)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"Error listing organizations: {e}")
        return []

def get_users_in_organization(organization_id):
    try:
        organization_url = f"{BASE_URL}/{organization_id}/users"
        response = requests.get(organization_url, auth=ADMIN_CREDENTIALS, headers=HEADERS)
        response.raise_for_status()
        users = response.json()
        return [{"loginOrEmail": user['login'], "role": user['role']} for user in users]
    except requests.exceptions.RequestException as e:
        print(f"Error getting users in organization {organization_id}: {e}")
        return []

def save_users_to_file(users_roles, output_filename):
    with open(output_filename, "w") as file:
        json.dump(users_roles, file, indent=4)
    print(f"Users and roles saved to {output_filename}")

def main():
    parser = argparse.ArgumentParser(description="Retrieve users and roles from Grafana organization(s).")
    parser.add_argument("--output", required=True, help="Path to the output JSON file (without .json extension)")
    parser.add_argument("--org-id", type=int, help="ID of the organization to capture users from")
    args = parser.parse_args()

    organizations = get_all_organizations()

    if args.org_id is not None:
        users_roles = get_users_in_organization(args.org_id)
        if users_roles:
            output_filename = args.output + ".json"
            save_users_to_file(users_roles, output_filename)
        else:
            print("No users and roles found in the organization.")
    else:
        all_users_roles = []
        for org in organizations:
            org_users_roles = get_users_in_organization(org['id'])
            all_users_roles.extend(org_users_roles)

        if all_users_roles:
            output_filename = args.output + ".json"
            save_users_to_file(all_users_roles, output_filename)
        else:
            print("No users and roles found in any organization.")

if __name__ == "__main__":
    main()