# General Variables
variable "gateway_ip_address" {
  description = "Gateway IP address"
  type        = string
}

variable "lxc_base_image" {
  description = "Template to clone"
  type        = string
  default     = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
}

variable "netmask" {
  description = "Network mask"
  type        = string
  default     = "/24"
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
}

# Proxmox
variable "proxmox_api_url" {
  description = "Proxmox API URL"
  type        = string
}

variable "proxmox_api_token_id" {
  description = "Proxmox API Token ID"
  type        = string
  sensitive   = true
}

variable "proxmox_api_token_secret" {
  description = "Proxmox API Token Secret"
  type        = string
  sensitive   = true
}

# Cloudflare
variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID"
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare Account ID"
  type        = string
  sensitive   = true
}

variable "cloudflare_tunnel_name" {
  description = "Cloudflare Tunnel Name"
  type        = string
  default     = "Terraform mediabox tunnel"
}

variable "cloudflare_token" {
  description = "Cloudflare API Token"
  type        = string
  sensitive   = true
}

# AdGuard
variable "adguard_node" {
  description = "Proxmox node for AdGuard"
  type        = string
}

variable "adguard_vm_id" {
  description = "VM ID for AdGuard"
  type        = number
}

variable "adguard_hostname" {
  description = "Hostname for AdGuard VM"
  type        = string
}

variable "adguard_storage" {
  description = "Storage for AdGuard VM"
  type        = string
}

variable "adguard_storage_size" {
  description = "Storage size for AdGuard VM"
  type        = string
}

variable "adguard_cores" {
  description = "Number of CPU cores for AdGuard VM"
  type        = number
}

variable "adguard_memory" {
  description = "Memory size for AdGuard VM"
  type        = number
}

variable "adguard_ip_address" {
  description = "IP address for AdGuard VM"
  type        = string
}

# Tailscale
variable "tailscale_node" {
  description = "Proxmox node for Tailscale"
  type        = string
}

variable "tailscale_vm_id" {
  description = "VM ID for Tailscale"
  type        = number
}

variable "tailscale_hostname" {
  description = "Hostname for Tailscale VM"
  type        = string
}

variable "tailscale_storage" {
  description = "Storage for Tailscale VM"
  type        = string
}

variable "tailscale_storage_size" {
  description = "Storage size for Tailscale VM"
  type        = string
}

variable "tailscale_cores" {
  description = "Number of CPU cores for Tailscale VM"
  type        = number
}

variable "tailscale_memory" {
  description = "Memory size for Tailscale VM"
  type        = number
}

variable "tailscale_ip_address" {
  description = "IP address for Tailscale VM"
  type        = string
}

variable "tailscale_api_key" {
  description = "API key for terraform provider"
  type        = string
}

variable "tailscale_tailnet" {
  description = "Tailnet"
  type        = string
}

# Mediabox
variable "mediabox_node" {
  description = "Proxmox node for Mediabox"
  type        = string
}

variable "mediabox_vm_id" {
  description = "VM ID for Mediabox"
  type        = number
}

variable "mediabox_hostname" {
  description = "Hostname for Mediabox VM"
  type        = string
}

variable "mediabox_vm_base_image" {
  description = "Base image for Mediabox VM"
  type        = string
  default     = "ubuntu-noble-server-cloud"
}

variable "mediabox_storage" {
  description = "Storage for Mediabox VM"
  type        = string
}

variable "mediabox_storage_size" {
  description = "Storage size for Mediabox VM"
  type        = number
}

variable "mediabox_cores" {
  description = "Number of CPU cores for Mediabox VM"
  type        = number
}

variable "mediabox_sockets" {
  description = "Number of sockets for Mediabox VM"
  type        = number
}

variable "mediabox_memory" {
  description = "Memory size for Mediabox VM"
  type        = number
}

variable "mediabox_ip_address" {
  description = "IP address for Mediabox VM"
  type        = string
}

variable "ansible_inventory" {
  description = "Ansible inventory file path"
  type        = string
  default     = "../ansible/inventory/hosts.yml"
}

variable "ansible_requirements" {
  description = "Ansible requirements file path"
  type        = string
  default     = "../ansible/requirements.yml"
}

variable "ansible_playbooks" {
  description = "Mapping of VM names to their respective Ansible playbooks"
  type        = map(string)
}

variable "mediabox_bios" {
  description = "Bios type"
  type        = string
}

variable "mediabox_machine_type" {
  description = "Machine type"
  type        = string
}

# Nginx Proxy Manager
variable "nginx_node" {
  description = "Proxmox node for NPM"
  type        = string
}

variable "nginx_vm_id" {
  description = "VM ID for NPM"
  type        = number
}

variable "nginx_hostname" {
  description = "Hostname for NPM"
  type        = string
}

variable "nginx_storage" {
  description = "Storage for NPM"
  type        = string
}

variable "nginx_storage_size" {
  description = "Storage size for NPM"
  type        = string
}

variable "nginx_cores" {
  description = "Number of CPU cores for NPM"
  type        = number
}

variable "nginx_memory" {
  description = "Memory size for NPM"
  type        = number
}

variable "nginx_ip_address" {
  description = "IP address for NPM"
  type        = string
}