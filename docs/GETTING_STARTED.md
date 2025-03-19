# Getting Started with DomoTron

This guide will help you set up and deploy your infrastructure using DomoTron, which orchestrates Terraform and Ansible to create a complete home lab infrastructure.

## Workflow Overview

1. **Terraform provisioning**: Creates VMs, LXC containers, Cloudflare tunnels, and Tailscale networks
2. **Integration step**: Terraform exports variables to Ansible
3. **Ansible configuration**: Configures the provisioned infrastructure with services

## Prerequisites

Before starting, ensure you have:

- [Terraform](https://www.terraform.io/downloads.html) v1.5.7 or newer
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) 2.12 or newer
- [Proxmox VE](https://www.proxmox.com/en/) cluster running
- Cloudflare account with API token (if using Cloudflare tunnels)
- Tailscale account with API key (if using Tailscale)

## Step 1: Configure Terraform

1. Navigate to the `terraform` directory
2. Copy `terraform.tfvars.example` to `terraform.tfvars`
3. Edit `terraform.tfvars` with your credentials and settings:

```hcl
proxmox_api_url = "https://your-proxmox-server:8006/api2/json"
proxmox_api_token_id = "your-token-id"
proxmox_api_token_secret = "your-token-secret"
cloudflare_token = "your-cloudflare-token"
cloudflare_account_id = "your-cloudflare-account"
tailscale_api_key = "your-tailscale-key"
tailscale_tailnet = "your-tailnet"
```

## Step 2: Run Terraform

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

This will:
1. Create your infrastructure on Proxmox
2. Set up Cloudflare tunnels
3. Configure Tailscale networks
4. Export variables to Ansible in `ansible/tf_ansible_vars.yml`

## Step 3: Run Ansible

```bash
cd ../ansible
ansible-playbook -i inventory/hosts.yml mediabox.yml
ansible-playbook -i inventory/hosts.yml adguard.yml
ansible-playbook -i inventory/hosts.yml nginx_proxy_manager.yml
ansible-playbook -i inventory/hosts.yml tailscale.yml
```

## Component Deployment

### Media Server

The MediaBox component includes:
- Jellyfin (media server)
- Sonarr, Radarr (media management)
- Prowlarr (indexer management)
- SABnzbd (download client)
- Jellyseerr (request management)

### AdGuard Home

Network-wide ad blocker and DNS server.

### Nginx Proxy Manager

Provides a web interface to manage Nginx as a reverse proxy with easy SSL configuration.

### Tailscale

Secure networking between all your devices.

## Troubleshooting

If you encounter issues:

1. **Terraform errors**: Check credentials and API endpoints in `terraform.tfvars`
2. **Ansible errors**: Ensure `tf_ansible_vars.yml` was generated correctly
3. **Connection errors**: Verify network connectivity to your Proxmox hosts

## Additional Documentation

- [Role Documentation](../ansible/roles/README.md)
- [Terraform Modules](../terraform/README.md)
- [Troubleshooting Guide](TROUBLESHOOTING.md)