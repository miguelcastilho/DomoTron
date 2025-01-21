#!/bin/bash

base64 -i inventory/prod.yml -o inventory/encoded_env_file
gh secret delete ENCODED_ENV_FILE
gh secret set ENCODED_ENV_FILE --body "$(cat inventory/encoded_env_file)"
rm inventory/encoded_env_file
