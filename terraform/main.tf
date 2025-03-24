# These resources are now defined in cloudflared.tf
# Generate Tailscale key - defined in proxmox_lxc.tf
# Generate random ID for Cloudflare tunnel - defined in cloudflared.tf
# Create Cloudflare tunnel - defined in cloudflared.tf

# AdGuard LXC
module "adguard" {
  source = "./modules/proxmox_lxc"

  target_node    = var.adguard_node
  vmid           = var.adguard_vm_id
  hostname       = var.adguard_hostname
  ostemplate     = var.lxc_base_image
  storage        = var.adguard_storage
  storage_size   = var.adguard_storage_size
  cores          = var.adguard_cores
  memory         = var.adguard_memory
  ip_address     = var.adguard_ip_address
  gateway        = var.gateway_ip_address
  netmask        = var.netmask
  ssh_public_key = var.ssh_public_key

  ansible_playbook  = var.ansible_playbooks.adguard
  ansible_inventory = var.ansible_inventory

  tags = {
    environment = "production"
    role        = "dns"
    app         = "adguard"
  }

  dependencies = [
    local_file.tf_ansible_vars
  ]
}

# Tailscale LXC
module "tailscale" {
  source = "./modules/proxmox_lxc"

  target_node    = var.tailscale_node
  vmid           = var.tailscale_vm_id
  hostname       = var.tailscale_hostname
  ostemplate     = var.lxc_base_image
  storage        = var.tailscale_storage
  storage_size   = var.tailscale_storage_size
  cores          = var.tailscale_cores
  memory         = var.tailscale_memory
  ip_address     = var.tailscale_ip_address
  gateway        = var.gateway_ip_address
  netmask        = var.netmask
  ssh_public_key = var.ssh_public_key

  ansible_playbook  = var.ansible_playbooks.tailscale
  ansible_inventory = var.ansible_inventory

  tags = {
    environment = "production"
    role        = "network"
    app         = "tailscale"
  }

  # dependencies = [
  #   local_file.tf_ansible_vars,
  #   tailscale_tailnet_key.tailscale_key
  # ]
}

# Nginx Proxy Manager LXC
module "nginx" {
  source = "./modules/proxmox_lxc"

  target_node    = var.nginx_node
  vmid           = var.nginx_vm_id
  hostname       = var.nginx_hostname
  ostemplate     = var.lxc_base_image
  storage        = var.nginx_storage
  storage_size   = var.nginx_storage_size
  cores          = var.nginx_cores
  memory         = var.nginx_memory
  ip_address     = var.nginx_ip_address
  gateway        = var.gateway_ip_address
  netmask        = var.netmask
  ssh_public_key = var.ssh_public_key

  ansible_playbook  = var.ansible_playbooks.nginx
  ansible_inventory = var.ansible_inventory

  tags = {
    environment = "production"
    role        = "proxy"
    app         = "nginx_proxy_manager"
  }

  # dependencies = [
  #   local_file.tf_ansible_vars
  # ]
}

# MediaBox VM
module "mediabox" {
  source = "./modules/proxmox_vm"

  target_node    = var.mediabox_node
  vmid           = var.mediabox_vm_id
  name           = var.mediabox_hostname
  clone          = var.mediabox_vm_base_image
  storage        = var.mediabox_storage
  storage_size   = var.mediabox_storage_size
  cores          = var.mediabox_cores
  sockets        = var.mediabox_sockets
  memory         = var.mediabox_memory
  ip_address     = var.mediabox_ip_address
  gateway        = var.gateway_ip_address
  netmask        = var.netmask
  ssh_public_key = var.ssh_public_key
  bios           = var.mediabox_bios
  machine        = var.mediabox_machine_type

  ansible_playbook     = var.ansible_playbooks.mediabox
  ansible_inventory    = var.ansible_inventory
  ansible_requirements = var.ansible_requirements

  tags = {
    environment = "production"
    role        = "media"
    app         = "mediabox"
  }

  # dependencies = [
  #   local_file.tf_ansible_vars
  # ]
}

# Removed ansible_integration module - using local_file.tf_ansible_vars from export.tf instead

# Proxmox host configuration - moved to proxmox_vm.tf