#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Print banner
echo -e "${BLUE}"
echo " ______   _______  _______  _______ _________ _______  _______  _       ";
echo "(  __  \ (  ___  )(       )(  ___  )\__   __/(  ____ )(  ___  )( (    /|";
echo "| (  \  )| (   ) || () () || (   ) |   ) (   | (    )|| (   ) ||  \  ( |";
echo "| |   ) || |   | || || || || |   | |   | |   | (____)|| |   | ||   \ | |";
echo "| |   | || |   | || |(_)| || |   | |   | |   |     __)| |   | || (\ \) |";
echo "| |   ) || |   | || |   | || |   | |   | |   | (\ (   | |   | || | \   |";
echo "| (__/  )| (___) || )   ( || (___) |   | |   | ) \ \__| (___) || )  \  |";
echo "(______/ (_______)|/     \|(_______)   )_(   |/   \__/(_______)|/    )_)";
echo "                                                                        ";
echo -e "${NC}"
echo -e "${GREEN}Automated Infrastructure Deployment${NC}"
echo ""

# Check configuration requirements
echo -e "${YELLOW}Checking configuration...${NC}"

# Check for terraform.tfvars
if [ ! -f "${SCRIPT_DIR}/terraform/terraform.tfvars" ]; then
  echo -e "${RED}Error: terraform.tfvars not found in terraform directory.${NC}"
  echo -e "Please create this file with your configuration values."
  echo -e "See terraform.tfvars.example for reference."
  exit 1
fi

# Check/create vault password file
if [ ! -f "${SCRIPT_DIR}/.vault_password" ]; then
  echo -e "${YELLOW}Vault password file not found. Creating a new one...${NC}"
  echo "Please enter a strong password for Ansible Vault encryption (press Enter to auto-generate):"
  read -s VAULT_PASS
  
  # If user pressed Enter (empty password), generate a secure random password
  if [ -z "$VAULT_PASS" ]; then
    echo -e "${BLUE}Generating a secure random password...${NC}"
    # Generate a 32-character random password with openssl
    if command -v openssl &> /dev/null; then
      VAULT_PASS=$(openssl rand -base64 24)
    else
      # Fallback if openssl is not available
      VAULT_PASS=$(cat /dev/urandom | LC_ALL=C tr -dc 'a-zA-Z0-9!@#$%^&*()_+?><~' | head -c 32)
    fi
    echo -e "${GREEN}Secure password generated!${NC}"
    echo -e "${YELLOW}Important: This password will not be shown again. It is securely stored in .vault_password${NC}"
  fi
  
  # Write the password to the vault file
  echo "$VAULT_PASS" > "${SCRIPT_DIR}/.vault_password"
  chmod 600 "${SCRIPT_DIR}/.vault_password"
  echo -e "${GREEN}Vault password file created!${NC}"
fi

# Export environment variables
export ANSIBLE_VAULT_PASSWORD_FILE="${SCRIPT_DIR}/.vault_password"

# Create an ansible.cfg file to ensure consistent vault password file usage
cat > "${SCRIPT_DIR}/ansible.cfg" << EOF
[defaults]
inventory = ${SCRIPT_DIR}/ansible/terraform_inventory.sh
vault_password_file = ${SCRIPT_DIR}/.vault_password
host_key_checking = False
roles_path = ${SCRIPT_DIR}/ansible/roles
retry_files_enabled = False
force_color = True
stdout_callback = yaml

# Parallelism settings
forks = 10

[ssh_connection]
pipelining = True
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o StrictHostKeyChecking=no

[diff]
always = True
context = 3
EOF

chmod 644 "${SCRIPT_DIR}/ansible.cfg"
echo -e "${GREEN}Vault password configured for Ansible and ansible.cfg created.${NC}"

echo -e "${YELLOW}Checking for required tools...${NC}"
# Check for Terraform
if ! command -v terraform &> /dev/null; then
  echo -e "${RED}Error: Terraform is not installed. Please install Terraform v1.5.7 or newer.${NC}"
  exit 1
fi

# Check for Ansible
if ! command -v ansible-playbook &> /dev/null; then
  echo -e "${RED}Error: Ansible is not installed. Please install Ansible 2.12 or newer.${NC}"
  exit 1
fi

echo -e "${GREEN}Starting DomoTron deployment...${NC}"
echo -e "${YELLOW}Step 1: Provisioning infrastructure with Terraform${NC}"

# Run Terraform
cd "${SCRIPT_DIR}/terraform"
echo "Initializing Terraform..."
terraform init

echo "Validating Terraform configuration..."
terraform validate

if [ $? -ne 0 ]; then
  echo -e "${RED}Terraform validation failed. Please fix the errors and try again.${NC}"
  exit 1
fi

echo "Planning Terraform changes..."
terraform plan -out=tfplan

echo "Applying Terraform changes - this may take some time..."
terraform apply tfplan

if [ $? -ne 0 ]; then
  echo -e "${RED}Terraform apply failed. Please check the errors above.${NC}"
  exit 1
fi

echo -e "${GREEN}Infrastructure provisioning completed successfully!${NC}"
echo -e "${BLUE}Note: Terraform has automatically triggered Ansible provisioning for each component.${NC}"
echo -e "${BLUE}The following steps are only necessary if you want to manually run Ansible again.${NC}"

# In case we want to manually run Ansible
echo -e "${YELLOW}Step 2 (Optional): Manually running Ansible to configure services${NC}"
echo -e "Would you like to manually run Ansible playbooks? (y/N): "
read -n 1 -r RUN_ANSIBLE
echo ""

if [[ $RUN_ANSIBLE =~ ^[Yy]$ ]]; then
  cd "${SCRIPT_DIR}/ansible"
  
  # Check if tf_ansible_vars.yml exists
  if [ ! -f tf_ansible_vars.yml ]; then
    echo -e "${RED}Error: tf_ansible_vars.yml not found. Terraform may have failed to generate it.${NC}"
    exit 1
  fi

  # Run playbooks in order using the ansible.cfg file for vault password
  echo -e "${YELLOW}Running Ansible playbooks...${NC}"
  ansible-playbook -i inventory/hosts.yml adguard.yml
  ansible-playbook -i inventory/hosts.yml tailscale.yml
  ansible-playbook -i inventory/hosts.yml nginx_proxy_manager.yml
  ansible-playbook -i inventory/hosts.yml mediabox.yml
fi

# Get IP addresses for the output message
cd "${SCRIPT_DIR}"
NGINX_IP=$(grep -A1 "nginx_proxy_manager:" ansible/inventory/hosts.yml | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+')
ADGUARD_IP=$(grep -A1 "adguard:" ansible/inventory/hosts.yml | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+')
MEDIABOX_IP=$(grep -A1 "mediabox:" ansible/inventory/hosts.yml | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+')

echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║        Deployment Completed Successfully   ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo -e "${BLUE}You can access your services at the following URLs:${NC}"
echo -e "- Nginx Proxy Manager: http://${NGINX_IP:-<nginx_ip>}:81"
echo -e "  - Default login: admin@example.com / changeme"
echo -e "- AdGuard Home: http://${ADGUARD_IP:-<adguard_ip>}:3000"
echo -e "- Jellyfin: http://${MEDIABOX_IP:-<mediabox_ip>}:8096"
echo -e "- Jellyseerr: http://${MEDIABOX_IP:-<mediabox_ip>}:5055"
echo ""
echo -e "${YELLOW}Important:${NC} Change default passwords immediately!"
echo -e "For more information, check the documentation in the docs/ directory."

exit 0