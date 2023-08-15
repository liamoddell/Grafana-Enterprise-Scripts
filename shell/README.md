# Grafana-Enterprise-Scripts

Shell scripts to automate certain Grafana Enterprise processes

# Commands / Usage

Defining which Grafana organisation to retrieve/import from/to is entirely dependent on the Service Account (previously API Key) used to run the command.

Standard usage is:

```
chmod+x ./<SCRIPT>.sh
```

```
./<SCRIPT>.sh <GRAFANA_INSTANCE> <SERVICE_ACCOUNT_TOKEN_FOR_ORG> <INPUT_DIR>OR<OUTPUT_DIR/>"
```
