#!/usr/bin/env python3
import json
import os
import sys
import subprocess
import argparse
from pathlib import Path

# Configuration
TERRAFORM_DIR = Path(__file__).parent.parent / "terraform/environments/prod"
ANSIBLE_DIR = Path(__file__).parent.parent / "ansible"


def get_terraform_output():
    """Get Terraform outputs by running 'terraform output -json'"""
    try:       
        # Change to the Terraform directory
        os.chdir(TERRAFORM_DIR)
        
        # Run terraform output command
        result = subprocess.run(
            ["terraform", "output", "-json"],
            capture_output=True,
            text=True,
            check=True
        )
        
        # Parse the JSON output
        return json.loads(result.stdout)
    except subprocess.CalledProcessError as e:
        print(f"Error running Terraform output: {e}", file=sys.stderr)
        print(f"stderr: {e.stderr}", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"Error parsing Terraform output JSON: {e}", file=sys.stderr)
        sys.exit(1)
    except FileNotFoundError as e:
        print(f"Error: File not found - {e}", file=sys.stderr)
        sys.exit(1)


def generate_inventory(terraform_output):
    """Generate Ansible inventory from Terraform output"""
    inventory = {
        "_meta": {
            "hostvars": {}
        }
    }
    
    # Process servers output
    if "servers" in terraform_output:
        servers = terraform_output["servers"]["value"]
        
        # Create groups based on roles
        for server_name, server_info in servers.items():
            # Add server to each role group
            for role in server_info.get("roles", []):
                if role not in inventory:
                    inventory[role] = {"hosts": []}
                inventory[role]["hosts"].append(server_info["ip"])
            
            # Add server to its named group
            if server_name not in inventory:
                inventory[server_name] = {"hosts": []}
            inventory[server_name]["hosts"] = [server_info["ip"]]
            
            # Add host vars
            inventory["_meta"]["hostvars"][server_info["ip"]] = {
                "ansible_host": server_info["ip"],
                "hostname": server_info.get("hostname", server_name)
            }
    
    # Add cloudflare information if available
    if "cloudflare" in terraform_output:
        cloudflare_info = terraform_output["cloudflare"]["value"]
        # Add to all group vars
        if "all" not in inventory:
            inventory["all"] = {"vars": {}}
        inventory["all"]["vars"] = {
            "cf_tunnel_id": cloudflare_info.get("tunnel_id", ""),
            "cf_account_id": cloudflare_info.get("account_id", ""),
            "cf_tunnel_name": cloudflare_info.get("tunnel_name", "")
        }
    
    return inventory


def main():
    """Main function"""
    parser = argparse.ArgumentParser(description='Terraform dynamic inventory for Ansible')
    parser.add_argument('--list', action='store_true', help='List all hosts and groups')
    parser.add_argument('--host', help='Get variables for a specific host')
    
    # Parse arguments
    args = parser.parse_args()
    
    # Process arguments
    if args.list:
        terraform_output = get_terraform_output()
        inventory = generate_inventory(terraform_output)
        print(json.dumps(inventory, indent=2))
    elif args.host:
        # Not implementing detailed --host since we include all host vars in --list
        print(json.dumps({}))
    else:
        parser.print_help()
        sys.exit(1)


if __name__ == "__main__":
    main()