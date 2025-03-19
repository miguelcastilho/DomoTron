# DomoTron

[![Validate Infrastructure](https://github.com/yourusername/DomoTron/actions/workflows/validate.yml/badge.svg)](https://github.com/yourusername/DomoTron/actions/workflows/validate.yml)

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
- [Python 3.8+](https://www.python.org/downloads/) (for the dynamic inventory script)
- Cloudflare account (optional, for tunnels)
- Tailscale account (optional, for secure networking)

## Installation

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/yourusername/DomoTron.git
   cd DomoTron
   ```

2. **Initial Setup:**

   Run the setup command to create necessary configuration files:

   ```bash
   make setup
   ```

   This will create a vault password file and configure ansible.cfg.

3. **Configure Variables:**

   ```bash
   cd terraform/environments/prod
   cp terraform.tfvars.example terraform.tfvars
   ```

   Edit `terraform.tfvars` with your environment-specific values.

## Quick Start

To deploy the complete infrastructure with a single command, use:

```bash
make deploy
```

This will:
1. Initialize Terraform
2. Apply the Terraform plan
3. Securely pass variables to Ansible
4. Execute Ansible playbooks to configure all services

## Detailed Usage

### Terraform Configuration

1. **Initialize Terraform:**

   ```bash
   make init
   ```

2. **Plan and Apply:**

   ```bash
   make plan
   make apply
   ```

   Terraform will:
   - Create VMs and LXCs on Proxmox
   - Set up Cloudflare tunnels
   - Configure Tailscale networking
   - Generate encrypted variables for Ansible
   - Execute Ansible playbooks

### Ansible Configuration

Terraform executes Ansible playbooks automatically after infrastructure provisioning, but you can also run them manually:

```bash
make provision  # Run all playbooks
make provision-adguard  # Run only the AdGuard playbook
```

## Project Structure

The project is organized with a modular, environment-based structure:

```
project/
├── ansible/              # Configuration management
│   ├── inventory/        # Host and group variables
│   ├── roles/            # Service-specific roles
│   ├── site.yml          # Main playbook that includes all others
│   └── *.yml             # Individual playbooks
├── docs/                 # Documentation
├── scripts/              # Utility scripts
├── terraform/            # Infrastructure as code
│   ├── environments/     # Environment-specific configurations
│   │   ├── prod/         # Production environment
│   │   └── dev/          # Development environment
│   └── modules/          # Reusable Terraform modules
│       ├── proxmox_vm/   # VM creation module
│       ├── proxmox_lxc/  # LXC creation module
│       └── ansible_integration/ # Ansible integration module
├── .github/workflows/    # CI/CD pipelines
└── Makefile              # Standardized commands
```

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