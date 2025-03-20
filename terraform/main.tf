# Generate Tailscale key
resource "tailscale_tailnet_key" "tailscale_key" {
  reusable            = true
  ephemeral           = true
  preauthorized       = true
  description         = "terraform"
  recreate_if_invalid = "always"
}

# Generate random ID for Cloudflare tunnel
resource "random_id" "tunnel_secret" {
  byte_length = 32
}

# Create Cloudflare tunnel
resource "cloudflare_zero_trust_tunnel_cloudflared" "mediabox" {
  name       = var.cloudflare_tunnel_name
  account_id = var.cloudflare_account_id
  secret     = random_id.tunnel_secret.b64_std
}

# AdGuard LXC
module "adguard" {
  source = "./modules/proxmox_lxc"

  target_node   = var.adguard_node
  vmid          = var.adguard_vm_id
  hostname      = var.adguard_hostname
  ostemplate    = var.lxc_base_image
  storage       = var.adguard_storage
  storage_size  = var.adguard_storage_size
  cores         = var.adguard_cores
  memory        = var.adguard_memory
  ip_address    = var.adguard_ip_address
  gateway       = var.gateway_ip_address
  netmask       = var.netmask
  ssh_public_key = var.ssh_public_key
  
  ansible_playbook  = var.ansible_playbooks.adguard
  ansible_inventory = var.ansible_inventory
  
  tags = {
    environment = "production"
    role        = "dns"
    app         = "adguard"
  }
  
  dependencies = [
    module.ansible_integration.ansible_variables_file
  ]
}

# Tailscale LXC
module "tailscale" {
  source = "./modules/proxmox_lxc"

  target_node   = var.tailscale_node
  vmid          = var.tailscale_vm_id
  hostname      = var.tailscale_hostname
  ostemplate    = var.lxc_base_image
  storage       = var.tailscale_storage
  storage_size  = var.tailscale_storage_size
  cores         = var.tailscale_cores
  memory        = var.tailscale_memory
  ip_address    = var.tailscale_ip_address
  gateway       = var.gateway_ip_address
  netmask       = var.netmask
  ssh_public_key = var.ssh_public_key
  
  ansible_playbook  = var.ansible_playbooks.tailscale
  ansible_inventory = var.ansible_inventory
  
  tags = {
    environment = "production"
    role        = "network"
    app         = "tailscale"
  }
  
  dependencies = [
    module.ansible_integration.ansible_variables_file,
    tailscale_tailnet_key.tailscale_key
  ]
}

# Nginx Proxy Manager LXC
module "nginx" {
  source = "./modules/proxmox_lxc"

  target_node   = var.nginx_node
  vmid          = var.nginx_vm_id
  hostname      = var.nginx_hostname
  ostemplate    = var.lxc_base_image
  storage       = var.nginx_storage
  storage_size  = var.nginx_storage_size
  cores         = var.nginx_cores
  memory        = var.nginx_memory
  ip_address    = var.nginx_ip_address
  gateway       = var.gateway_ip_address
  netmask       = var.netmask
  ssh_public_key = var.ssh_public_key
  
  ansible_playbook  = var.ansible_playbooks.nginx
  ansible_inventory = var.ansible_inventory
  
  tags = {
    environment = "production"
    role        = "proxy"
    app         = "nginx_proxy_manager"
  }
  
  dependencies = [
    module.ansible_integration.ansible_variables_file
  ]
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
  additional_wait = 60
  
  ansible_playbook    = var.ansible_playbooks.mediabox
  ansible_inventory   = var.ansible_inventory
  ansible_requirements = var.ansible_requirements
  
  tags = {
    environment = "production"
    role        = "media"
    app         = "mediabox"
  }
  
  dependencies = [
    module.ansible_integration.ansible_variables_file
  ]
}

# Ansible integration module
module "ansible_integration" {
  source = "./modules/ansible_integration"
  
  project_root = abspath("${path.module}/..")
  vault_password_file = ".vault_password"
  
  sensitive_variables = {
    cf_tunnel_secret = random_id.tunnel_secret.b64_std
    cf_token         = var.cloudflare_token
    tailscale_authkey = tailscale_tailnet_key.tailscale_key.key
  }
  
  non_sensitive_variables = {
    cf_tunnel_id        = cloudflare_zero_trust_tunnel_cloudflared.mediabox.id
    cf_account_id       = var.cloudflare_account_id
    cf_tunnel_name      = cloudflare_zero_trust_tunnel_cloudflared.mediabox.name
    mediabox_ip_address = var.mediabox_ip_address
  }
  
  output_file = "ansible/tf_ansible_vars.yml"
  
  dependencies = [
    tailscale_tailnet_key.tailscale_key,
    cloudflare_zero_trust_tunnel_cloudflared.mediabox,
    random_id.tunnel_secret
  ]
}

# Proxmox host configuration
resource "null_resource" "execute_ansible_on_proxmox" {
  provisioner "local-exec" {
    command = "ansible-playbook -i ${var.ansible_inventory} ${var.ansible_playbooks.proxmox}"
  }
  
  depends_on = [
    module.ansible_integration.ansible_variables_file
  ]
}