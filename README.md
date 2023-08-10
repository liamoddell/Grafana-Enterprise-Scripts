# Grafana-Enterprise-Scripts
Random scripts to automate certain Grafana Enterprise processes

# Commands / Usage

**get_all_users_and_roles.py**: 

Uses the admin basic authorisation to capture all users and their roles from all organisations on a target instance. 

_--output_ is used to specify a file to output this to, with '.json' automatically appended by the script.

_--org-id_ (optional) is used to specify the organisation that you would like to capture the user data from.

**add_users_to_organisation.py**: 

Uses the admin basic authorisation and an input file (created by get_all_users_and_roles.py) to list all available organisations, and then add users to a specific organisation based on a command line input.

_--file_ the file from which you captured the usernames and roles in JSON format.
