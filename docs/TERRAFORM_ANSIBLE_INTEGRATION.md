# Terraform-Ansible Integration

This document explains how Terraform and Ansible are integrated in the DomoTron project to create a seamless deployment pipeline.

## Overview

DomoTron uses a modular approach to integrate Terraform (for infrastructure provisioning) with Ansible (for configuration management). This integration provides:

1. **Clean separation of concerns**: Terraform handles infrastructure, Ansible handles configuration
2. **Secure variable passing**: Sensitive data is encrypted with Ansible Vault
3. **Idempotent operations**: Changes are applied only when needed
4. **Modular design**: Reusable components can be combined in different ways
5. **Environment-based structure**: Configurations for different environments (prod, dev)

## Integration Architecture

```
┌─────────────────────┐     ┌──────────────────┐     ┌────────────────────┐
│                     │     │                  │     │                    │
│  Terraform Modules  │────▶│  Variable Export │────▶│  Ansible Playbooks │
│                     │     │                  │     │                    │
└─────────────────────┘     └──────────────────┘     └────────────────────┘
        │                           │                          ▲
        │                           │                          │
        │                           ▼                          │
        │               ┌──────────────────────┐               │
        └───────────▶  │  Dynamic Inventory    │  ◀────────────┘
                        └──────────────────────┘
```

## Key Components

### 1. Ansible Integration Module

The `ansible_integration` Terraform module:
- Creates the ansible.cfg file with proper configuration
- Generates a variables file with both sensitive and non-sensitive data
- Encrypts sensitive variables using Ansible Vault
- Provides proper dependency tracking

### 2. Dynamic Inventory

The Python-based dynamic inventory system:
- Reads Terraform outputs to generate an Ansible inventory
- Creates proper host and group variables
- Updates automatically when infrastructure changes
- Maps servers to roles for targeted deployment

### 3. Modular Infrastructure

Infrastructure is defined using reusable modules:
- `proxmox_vm`: Manages VM creation and configuration
- `proxmox_lxc`: Manages LXC creation and configuration
- Each module has integrated Ansible provisioning capabilities

### 4. Environment Separation

The environments directory structure:
- Separates production from development configurations
- Allows different variables for each environment
- Maintains consistency through shared modules

## Workflow

1. **Infrastructure Provisioning**:
   - Terraform creates the infrastructure using environment-specific configurations
   - Resources are tagged for better organization and tracking
   - Dependencies are properly managed to ensure correct order

2. **Variable Passing**:
   - Terraform exports values needed by Ansible in two ways:
     - Encrypted variables file for sensitive data
     - Standard Terraform outputs for non-sensitive data
   - The Ansible integration module handles secure encryption

3. **Inventory Generation**:
   - The dynamic inventory script generates an inventory from Terraform outputs
   - Servers are organized by roles and groups
   - Host variables are set based on Terraform outputs

4. **Configuration Management**:
   - Ansible playbooks are executed with the correct inventory
   - The vault password is securely used via ansible.cfg
   - Playbooks are organized by role and function

## Security Considerations

- Sensitive variables are encrypted using Ansible Vault
- The vault password file has strict permissions (0600)
- Terraform state is kept secure (ideally in remote backend)
- GitHub Actions secrets are used for CI/CD integration

## Error Handling

- Resource dependencies are explicitly defined
- Conditional execution prevents broken states
- Wait periods ensure systems are ready before configuration
- Validation steps verify configurations before applying

## Usage

See the [README.md](../README.md) and [Makefile](../Makefile) for common operations:

- `make setup`: Initial configuration
- `make init`: Initialize Terraform
- `make plan`: Plan Terraform changes
- `make apply`: Apply Terraform changes
- `make provision`: Run Ansible playbooks

## CI/CD Integration

The project includes GitHub Actions workflows:
- `validate.yml`: Validates Terraform and Ansible configurations
- `deploy.yml`: Applies changes to the selected environment

## Troubleshooting

If you encounter issues with the integration:

1. Check the Terraform state to verify resources are created correctly
2. Verify the dynamic inventory is generating the expected output
3. Ensure the vault password file is accessible and has correct permissions
4. Review the ansible.cfg file to ensure it's configured correctly
5. Enable verbose logging in Ansible with `-v` flag for more details