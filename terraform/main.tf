###################################
# DomoTron Infrastructure
###################################

terraform {
  required_version = ">= 1.5.7"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.5.2"
    }
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc9"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.52.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.1"
    }
    ansible = {
      source  = "nbering/ansible"
      version = "1.0.4"
    }
    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.18.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.3"
    }
  }
}

###################################
# PROVIDERS
###################################

provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
}

provider "cloudflare" {
  api_token = var.cloudflare_token
}

provider "tailscale" {
  api_key = var.tailscale_api_key
  tailnet = var.tailscale_tailnet
}

###################################
# TAILSCALE & CLOUDFLARED
###################################

# Generate Tailscale key
resource "tailscale_tailnet_key" "tailscale_key" {
  reusable            = local.tailscale_key_reusable
  ephemeral           = local.tailscale_key_ephemeral
  preauthorized       = local.tailscale_key_preauthorized
  description         = var.tailscale_key_description
  recreate_if_invalid = local.tailscale_key_recreate_if_invalid
}

# Generate random ID for Cloudflare tunnel
resource "random_id" "cloudflare_tunnel_secret" {
  byte_length = local.cloudflare_tunnel_secret_random_byte_length
}

# Create Cloudflare tunnel
resource "cloudflare_zero_trust_tunnel_cloudflared" "mediabox_tunnel" {
  account_id = var.cloudflare_account_id
  name       = var.cloudflare_tunnel_name
  secret     = random_id.cloudflare_tunnel_secret.b64_std
}

# Creates the CNAME records to route to the tunnel
resource "cloudflare_record" "cname_records" {
  for_each = var.cloudflare_cname_records_name

  zone_id = var.cloudflare_zone_id
  name = each.value
  content = cloudflare_zero_trust_tunnel_cloudflared.mediabox_tunnel.cname
  type    = local.cloudflare_cname_type
  proxied = local.cloudflare_cname_proxied
}

# Creates the configuration for the tunnel
resource "cloudflare_zero_trust_tunnel_cloudflared_config" "mediabox_config" {
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.mediabox_tunnel.id
  account_id = var.cloudflare_account_id
  config {
    ingress_rule {
      hostname = cloudflare_record.cname_records["jellyseerr"].hostname
      service  = "http://${cidrhost(var.network_address, var.mediabox_vm_id)}:5055"
    }
    ingress_rule {
      hostname = cloudflare_record.cname_records["jellyfin"].hostname
      service  = "http://${cidrhost(var.network_address, var.mediabox_vm_id)}:8096"
    }
    ingress_rule {
      hostname = cloudflare_record.cname_records["homeassistant"].hostname
      service  = "http://${cidrhost(var.network_address, var.mediabox_vm_id)}:8123"
    }
    ingress_rule {
      service = "http_status:404"
    }
  }
}

###################################
# PROXMOX LXC CONTAINERS
###################################

# AdGuard LXC
resource "proxmox_lxc" "adguard_container" {
  target_node  = var.adguard_node
  vmid         = var.adguard_vm_id
  hostname     = var.adguard_hostname
  ostemplate   = var.lxc_base_image
  unprivileged = var.adguard_unprivileged
  rootfs {
    storage = var.adguard_storage
    size    = var.adguard_storage_size
  }
  cores  = var.adguard_cores
  memory = var.adguard_memory
  network {
    name   = var.adguard_network_name
    bridge = var.adguard_bridge
    gw     = var.gateway_ip_address
    ip     = "${cidrhost(var.network_address, var.adguard_vm_id)}/${split("/", var.network_address)[1]}"
  }
  ssh_public_keys = var.ssh_public_key
  onboot          = var.adguard_onboot
  start           = var.adguard_start

  provisioner "local-exec" {
    command = "ansible-playbook -i ${local.ansible_inventory} ${local.ansible_playbooks.adguard}"
  }

  depends_on = [
    local_file.ansible_vars
  ]
}

# Tailscale LXC
resource "proxmox_lxc" "tailscale_container" {
  target_node  = var.tailscale_node
  vmid         = var.tailscale_vm_id
  hostname     = var.tailscale_hostname
  ostemplate   = var.lxc_base_image
  unprivileged = var.tailscale_unprivileged
  rootfs {
    storage = var.tailscale_storage
    size    = var.tailscale_storage_size
  }
  cores  = var.tailscale_cores
  memory = var.tailscale_memory
  network {
    name   = var.tailscale_network_name
    bridge = var.tailscale_bridge
    gw     = var.gateway_ip_address
    ip     = "${cidrhost(var.network_address, var.tailscale_vm_id)}/${split("/", var.network_address)[1]}"
  }
  ssh_public_keys = var.ssh_public_key
  onboot          = var.tailscale_onboot
  start           = var.tailscale_start

  provisioner "local-exec" {
    command = "ansible-playbook -i ${local.ansible_inventory} ${local.ansible_playbooks.tailscale}"
  }

  depends_on = [
    local_file.ansible_vars,
    tailscale_tailnet_key.tailscale_key
  ]
}

# Nginx Proxy Manager LXC
resource "proxmox_lxc" "nginx_container" {
  target_node  = var.nginx_node
  vmid         = var.nginx_vm_id
  hostname     = var.nginx_hostname
  ostemplate   = var.lxc_base_image
  unprivileged = var.nginx_unprivileged
  rootfs {
    storage = var.nginx_storage
    size    = var.nginx_storage_size
  }
  cores  = var.nginx_cores
  memory = var.nginx_memory
  network {
    name   = var.nginx_network_name
    bridge = var.nginx_bridge
    gw     = var.gateway_ip_address
    ip     = "${cidrhost(var.network_address, var.nginx_vm_id)}/${split("/", var.network_address)[1]}"
  }
  ssh_public_keys = var.ssh_public_key
  onboot          = var.nginx_onboot
  start           = var.nginx_start

  provisioner "local-exec" {
    command = "ansible-playbook -i ${local.ansible_inventory} ${local.ansible_playbooks.nginx}"
  }

  depends_on = [
    local_file.ansible_vars
  ]
}

###################################
# PROXMOX VMs
###################################

# MediaBox VM
resource "proxmox_vm_qemu" "mediabox_vm" {
  target_node             = var.mediabox_node
  vmid                    = var.mediabox_vm_id
  name                    = var.mediabox_hostname
  clone                   = var.mediabox_vm_base_image
  agent                   = var.mediabox_proxmox_agent
  os_type                 = var.mediabox_os_type
  bios                    = var.mediabox_bios
  machine                 = var.mediabox_machine_type
  cloudinit_cdrom_storage = var.mediabox_storage
  cores                   = var.mediabox_cores
  sockets                 = var.mediabox_sockets
  cpu                     = var.mediabox_cpu
  numa                    = false
  memory                  = var.mediabox_memory
  balloon                 = var.mediabox_memory
  scsihw                  = var.mediabox_scsi_controller
  bootdisk                = var.mediabox_bootdisk
  onboot                  = var.mediabox_onboot
  full_clone              = var.mediabox_full_clone
  disks {
    scsi {
      scsi0 {
        disk {
          size    = var.mediabox_storage_size
          storage = var.mediabox_storage
          backup  = var.mediabox_disk_backup
          discard = var.mediabox_disk_discard
        }
      }
    }
  }
  network {
    model  = var.mediabox_network_model
    bridge = var.mediabox_network_bridge
  }
  ipconfig0 = "ip=${cidrhost(var.network_address, var.mediabox_vm_id)}/${split("/", var.network_address)[1]},gw=${var.gateway_ip_address}"
  sshkeys   = var.ssh_public_key

  # Run the Ansible playbook for MediaBox
  provisioner "local-exec" {
    command = "ansible-playbook -i ${local.ansible_inventory} ${local.ansible_playbooks.mediabox}"
  }

  depends_on = [
    local_file.ansible_vars,
    null_resource.ansible_galaxy_install
  ]
}

###################################
# PROXMOX HOST CONFIGURATION
###################################

# Configure the Proxmox host itself
resource "null_resource" "proxmox_ansible_config" {
  triggers = {
    ansible_playbook  = local.ansible_playbooks.proxmox
    ansible_proxmox_md5 = filemd5("${path.module}/${local.ansible_playbooks.proxmox}")
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ${local.ansible_inventory} ${local.ansible_playbooks.proxmox}"
  }
}

###################################
# ANSIBLE INTEGRATION
###################################

# Generate tf_ansible_vars.yml with properly structured and sensitive variables
resource "local_file" "ansible_vars" {
  content = templatefile("${path.module}/templates/tf_ansible_vars.yml.tpl", {
    cf_tunnel_id        = cloudflare_zero_trust_tunnel_cloudflared.mediabox_tunnel.id
    cf_account_id       = var.cloudflare_account_id
    cf_tunnel_name      = cloudflare_zero_trust_tunnel_cloudflared.mediabox_tunnel.name
    cf_tunnel_secret    = random_id.cloudflare_tunnel_secret.b64_std
    cf_token            = var.cloudflare_token
    tailscale_authkey   = tailscale_tailnet_key.tailscale_key.key
    # mediabox_ip_address = cidrhost(var.network_address, var.mediabox_vm_id)
  })

  filename = "${path.module}/${local.ansible_tf_vars_file}"

  depends_on = [
    tailscale_tailnet_key.tailscale_key,
    cloudflare_zero_trust_tunnel_cloudflared.mediabox_tunnel,
    random_id.cloudflare_tunnel_secret
  ]

  provisioner "local-exec" {
    command = "ansible-vault encrypt ${path.module}/${local.ansible_tf_vars_file}"
  }
}

resource "null_resource" "ansible_galaxy_install" {
  triggers = {
    ansible_requirements = local.ansible_requirements
    requirements_md5 = filemd5("${path.module}/${local.ansible_requirements}")
  }

  provisioner "local-exec" {
    command = "ansible-galaxy install -r ${local.ansible_requirements}"
  }
}
