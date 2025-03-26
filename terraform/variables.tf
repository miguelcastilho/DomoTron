// General variables
variable "network_address" {
  type        = string
  description = "Network address in CIDR notation (e.g. 192.168.1.0/24)."
}

variable "gateway_ip_address" {
  type        = string
  description = "Gateway IP address for the network."
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key."
}

variable "lxc_base_image" {
  type        = string
  description = "Base image for LXC containers."
}

// Proxmox provider variables
variable "proxmox_api_url" {
  type        = string
  description = "Proxmox API URL endpoint."
}

variable "proxmox_api_token_id" {
  type        = string
  description = "Proxmox API token ID."
}

variable "proxmox_api_token_secret" {
  type        = string
  description = "Proxmox API token secret."
}

// Cloudflare provider variables
variable "cloudflare_token" {
  type        = string
  description = "Cloudflare API token."
}

// Tailscale provider variables
variable "tailscale_api_key" {
  type        = string
  description = "Tailscale API key."
}

variable "tailscale_tailnet" {
  type        = string
  description = "Tailscale tailnet."
}

// Terraform vars for keys and tunnels
variable "tailscale_key_description" {
  type        = string
  description = "Description for the Tailscale key."
}

variable "cloudflare_zone_id" {
  type        = string
  description = "Cloudflare zone ID."
}

variable "cloudflare_account_id" {
  type        = string
  description = "Cloudflare account ID."
}

variable "cloudflare_tunnel_name" {
  type        = string
  description = "Cloudflare tunnel name."
}

variable "cloudflare_cname_records_name" {
  type        = map(string)
  description = "Map of Cloudflare CNAME record names."
}

// AdGuard LXC variables
variable "adguard_node" {
  type        = string
  description = "Proxmox node where AdGuard runs."
}

variable "adguard_vm_id" {
  type        = number
  description = "VM ID for the AdGuard container."
}

variable "adguard_hostname" {
  type        = string
  description = "Hostname for the AdGuard container."
}

variable "adguard_storage" {
  type        = string
  description = "Storage pool name for AdGuard."
}

variable "adguard_storage_size" {
  type        = string
  description = "Storage size for AdGuard (e.g. 2G)."
}

variable "adguard_cores" {
  type        = number
  description = "Number of CPU cores allocated to AdGuard."
}

variable "adguard_memory" {
  type        = number
  description = "Memory (in MB) allocated to AdGuard."
}

variable "adguard_unprivileged" {
  type        = bool
  description = "Whether the AdGuard LXC container is unprivileged."
}

variable "adguard_network_name" {
  type        = string
  description = "Network interface name for AdGuard."
}

variable "adguard_bridge" {
  type        = string
  description = "Network bridge for AdGuard."
}

variable "adguard_onboot" {
  type        = bool
  description = "Whether AdGuard starts on boot."
}

variable "adguard_start" {
  type        = bool
  description = "Whether to start the AdGuard container."
}

// Tailscale LXC variables
variable "tailscale_node" {
  type        = string
  description = "Proxmox node where Tailscale runs."
}

variable "tailscale_vm_id" {
  type        = number
  description = "VM ID for the Tailscale container."
}

variable "tailscale_hostname" {
  type        = string
  description = "Hostname for the Tailscale container."
}

variable "tailscale_storage" {
  type        = string
  description = "Storage pool name for Tailscale."
}

variable "tailscale_storage_size" {
  type        = string
  description = "Storage size for Tailscale (e.g. 2G)."
}

variable "tailscale_cores" {
  type        = number
  description = "Number of CPU cores allocated to Tailscale."
}

variable "tailscale_memory" {
  type        = number
  description = "Memory (in MB) allocated to Tailscale."
}

variable "tailscale_unprivileged" {
  type        = bool
  description = "Whether the Tailscale LXC container is unprivileged."
}

variable "tailscale_network_name" {
  type        = string
  description = "Network interface name for Tailscale."
}

variable "tailscale_bridge" {
  type        = string
  description = "Network bridge for Tailscale."
}

variable "tailscale_onboot" {
  type        = bool
  description = "Whether Tailscale starts on boot."
}

variable "tailscale_start" {
  type        = bool
  description = "Whether to start the Tailscale container."
}

// Nginx LXC variables
variable "nginx_node" {
  type        = string
  description = "Proxmox node where Nginx runs."
}

variable "nginx_vm_id" {
  type        = number
  description = "VM ID for the Nginx container."
}

variable "nginx_hostname" {
  type        = string
  description = "Hostname for the Nginx container."
}

variable "nginx_storage" {
  type        = string
  description = "Storage pool name for Nginx."
}

variable "nginx_storage_size" {
  type        = string
  description = "Storage size for Nginx (e.g. 8G)."
}

variable "nginx_cores" {
  type        = number
  description = "Number of CPU cores allocated to Nginx."
}

variable "nginx_memory" {
  type        = number
  description = "Memory (in MB) allocated to Nginx."
}

variable "nginx_unprivileged" {
  type        = bool
  description = "Whether the Nginx LXC container is unprivileged."
}

variable "nginx_network_name" {
  type        = string
  description = "Network interface name for Nginx."
}

variable "nginx_bridge" {
  type        = string
  description = "Network bridge for Nginx."
}

variable "nginx_onboot" {
  type        = bool
  description = "Whether Nginx starts on boot."
}

variable "nginx_start" {
  type        = bool
  description = "Whether to start the Nginx container."
}

// Mediabox VM variables
variable "mediabox_node" {
  type        = string
  description = "Proxmox node where Mediabox runs."
}

variable "mediabox_vm_id" {
  type        = number
  description = "VM ID for the Mediabox VM."
}

variable "mediabox_hostname" {
  type        = string
  description = "Hostname for the Mediabox VM."
}

variable "mediabox_vm_base_image" {
  type        = string
  description = "Base image for the Mediabox VM."
}

variable "mediabox_storage" {
  type        = string
  description = "Storage pool name for Mediabox."
}

variable "mediabox_storage_size" {
  type        = number
  description = "Storage size for the Mediabox VM."
}

variable "mediabox_cores" {
  type        = number
  description = "Number of CPU cores allocated to Mediabox."
}

variable "mediabox_sockets" {
  type        = number
  description = "Number of CPU sockets for Mediabox."
}

variable "mediabox_memory" {
  type        = number
  description = "Memory (in MB) allocated to Mediabox."
}

variable "mediabox_bios" {
  type        = string
  description = "BIOS type for the Mediabox VM."
}

variable "mediabox_machine_type" {
  type        = string
  description = "Machine type for the Mediabox VM."
}

variable "mediabox_proxmox_agent" {
  type        = number
  description = "Proxmox agent setting for the Mediabox VM."
}

variable "mediabox_os_type" {
  type        = string
  description = "OS type for the Mediabox VM."
}

variable "mediabox_cpu" {
  type        = string
  description = "CPU type for the Mediabox VM."
}

variable "mediabox_scsi_controller" {
  type        = string
  description = "SCSI controller type for the Mediabox VM."
}

variable "mediabox_bootdisk" {
  type        = string
  description = "Boot disk for the Mediabox VM."
}

variable "mediabox_onboot" {
  type        = bool
  description = "Whether the Mediabox VM starts on boot."
}

variable "mediabox_full_clone" {
  type        = bool
  description = "Whether the Mediabox VM is fully cloned."
}

variable "mediabox_disk_backup" {
  type        = bool
  description = "Whether disk backup is enabled for the Mediabox VM."
}

variable "mediabox_disk_discard" {
  type        = bool
  description = "Whether disk discard is enabled for the Mediabox VM."
}

variable "mediabox_network_model" {
  type        = string
  description = "Network model for the Mediabox VM."
}

variable "mediabox_network_bridge" {
  type        = string
  description = "Network bridge for the Mediabox VM."
}
