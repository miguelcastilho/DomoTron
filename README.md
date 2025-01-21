# HomeServeMate

## Overview

HomeServeMate is a project designed to automate the deployment and configuration of infrastructure on Proxmox using Terraform and Ansible. The Terraform scripts are used to provision the infrastructure, while Ansible is utilized to configure virtual machines (VMs) and Linux containers (LXC).

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Terraform Configuration](#terraform-configuration)
- [Ansible Configuration](#ansible-configuration)
- [Contributing](#contributing)
- [License](#license)

## Prerequisites

Before you begin, ensure you have the following installed:

- [Terraform](https://www.terraform.io/downloads.html)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- [Proxmox VE](https://www.proxmox.com/en/)

## Installation

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/yourusername/HomeServeMate.git
   cd HomeServeMate
   ```

2. **Set Up Environment Variables:**

   Ensure you have the necessary environment variables set up for Proxmox and other services. This typically includes API tokens, usernames, and passwords.

3. **Terraform Initialization:**

   Navigate to the `terraform` directory and initialize Terraform.

   ```bash
   cd terraform
   terraform init
   ```

## Usage

### Terraform Configuration

1. **Customize Variables:**

   Edit the `terraform.tfvars` file to configure the variables specific to your environment.

   ```hcl
   proxmox_endpoint = "https://proxmox.example.com:8006"
   proxmox_user     = "root@pam"
   proxmox_password = "yourpassword"
   ```

2. **Deploy Infrastructure:**

   Run the following commands to plan and apply the Terraform configuration.

   ```bash
   terraform plan
   terraform apply
   ```

### Ansible Configuration

1. **Inventory Setup:**

   Edit the inventory files located in `ansible/inventory` to match your infrastructure setup.

2. **Run Ansible Playbooks:**

   Execute the Ansible playbooks to configure your VMs and LXCs.

   ```bash
   ansible-playbook -i ansible/inventory/hosts.yml ansible/playbook.yml
   ```

## Terraform structure

The `terraform` directory contains all the necessary files for provisioning the infrastructure:

- `main.tf`: Main configuration file for Terraform.
- `variables.tf`: Variable definitions.
- `terraform.tfvars`: Variable values specific to your environment.
- `providers.tf`: Provider configurations.
- `export.tf`: Resource export configurations.

## Ansible structure

The `ansible` directory contains playbooks and roles for configuring the VMs and LXCs:

- `playbook.yml`: Main playbook for Ansible.
- `roles/`: Directory containing various roles for service and application configurations.
- `inventory/`: Directory containing inventory files and group variables.

## Contributing

We welcome contributions! Please read our [contributing guidelines](CONTRIBUTING.md) to get started.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
