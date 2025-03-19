#!/bin/bash
# Wrapper script for Terraform inventory

# Navigate to the project root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Execute the Python inventory script
python3 "$PROJECT_ROOT/scripts/terraform_inventory.py" "$@"