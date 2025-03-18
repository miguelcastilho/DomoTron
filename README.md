# DomoTron

## Overview

DomoTron is a project designed to automate the deployment and configuration of infrastructure on Proxmox using Terraform and Ansible. The Terraform scripts are used to provision the infrastructure, while Ansible is utilized to configure virtual machines (VMs) and Linux containers (LXC).

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Detailed Usage](#detailed-usage)
  - [Terraform Configuration](#terraform-configuration)
  - [Ansible Configuration](#ansible-configuration)
- [Project Structure](#project-structure)
- [Provided Services](#provided-services)
- [Documentation](#documentation)
- [Contributing](#contributing)
- [License](#license)

## Prerequisites

Before you begin, ensure you have the following installed:

- [Terraform](https://www.terraform.io/downloads.html) v1.5.7 or newer
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) 2.12 or newer
- [Proxmox VE](https://www.proxmox.com/en/)
- Cloudflare account (optional, for tunnels)
- Tailscale account (optional, for secure networking)

## Installation

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/yourusername/DomoTron.git
   cd DomoTron
   ```

2. **Create Vault Password File:**

   Create a `.vault_pass.txt` file in the root directory with a secure password for Ansible Vault encryption.

   ```bash
   echo "your-secure-password" > .vault_pass.txt
   chmod 600 .vault_pass.txt
   ```

3. **Configure Variables:**

   Copy `terraform.tfvars.example` to `terraform.tfvars` and edit with your environment-specific values.

## Quick Start

To deploy the complete infrastructure with a single command, use the included deployment script:

```bash
./deploy.sh
```

This script will:
1. Run Terraform to provision infrastructure
2. Securely pass variables to Ansible
3. Execute Ansible playbooks to configure all services

## Detailed Usage

### Terraform Configuration

1. **Initialize Terraform:**

   ```bash
   cd terraform
   terraform init
   ```

2. **Plan and Apply:**

   ```bash
   terraform plan
   terraform apply
   ```

   Terraform will automatically:
   - Create VMs and LXCs on Proxmox
   - Set up Cloudflare tunnels
   - Configure Tailscale networking
   - Generate encrypted variables for Ansible
   - Execute Ansible playbooks

### Ansible Configuration

Terraform executes Ansible playbooks automatically after infrastructure provisioning, but you can also run them manually:

```bash
cd ansible
ansible-playbook -i inventory/hosts.yml mediabox.yml --vault-password-file ../.vault_pass.txt
```

## Project Structure

- **terraform/**: Infrastructure as code
  - `providers.tf`: Provider configurations
  - `proxmox_vm.tf`: VM definitions
  - `proxmox_lxc.tf`: Container definitions
  - `cloudflared.tf`: Cloudflare tunnel configuration
  - `export.tf`: Exports variables to Ansible
  
- **ansible/**: Configuration management
  - `roles/`: Service-specific roles
  - `inventory/`: Host and group definitions
  - Various playbooks (mediabox.yml, adguard.yml, etc.)
  
- **docs/**: Documentation
  - `GETTING_STARTED.md`: Detailed guide for beginners
  - `TERRAFORM_ANSIBLE_INTEGRATION.md`: Integration details

## Provided Services

DomoTron sets up the following services:

- **Media Server**: Jellyfin, Sonarr, Radarr, Prowlarr, SABnzbd
- **AdGuard Home**: Network-wide ad blocking and DNS
- **Nginx Proxy Manager**: Reverse proxy with SSL management
- **Tailscale**: Secure networking between devices

## Documentation

Additional documentation can be found in the `docs/` directory:

- [Getting Started Guide](docs/GETTING_STARTED.md)
- [Terraform-Ansible Integration](docs/TERRAFORM_ANSIBLE_INTEGRATION.md)

## Contributing

We welcome contributions! Please read our [contributing guidelines](CONTRIBUTING.md) to get started.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.