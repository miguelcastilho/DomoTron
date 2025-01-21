######### AdGuard
resource "proxmox_lxc" "adguard" {
  target_node  = var.adguard_node
  vmid         = var.adguard_vm_id
  hostname     = var.adguard_hostname
  ostemplate   = var.lxc_base_image
  unprivileged = true
  rootfs {
    storage = var.adguard_storage
    size    = var.adguard_storage_size
  }
  cores  = var.adguard_cores
  memory = var.adguard_memory
  network {
    name   = "eth0"
    bridge = "vmbr0"
    gw     = var.gateway_ip_address
    ip     = "${var.adguard_ip_address}${var.netmask}"
  }
  ssh_public_keys = var.ssh_public_key
  onboot          = true
  start           = true

  provisioner "local-exec" {
    command = "ansible-playbook -i ${var.ansible_inventory} ${var.ansible_playbooks.adguard} --vault-password-file .vault_pass.txt"
  }
}

###### Tailscale
resource "tailscale_tailnet_key" "tailscale_key" {
  reusable            = true
  ephemeral           = true
  preauthorized       = true
  description         = "terraform"
  recreate_if_invalid = "always"
}

resource "proxmox_lxc" "tailscale" {
  target_node  = var.tailscale_node
  vmid         = var.tailscale_vm_id
  hostname     = var.tailscale_hostname
  ostemplate   = var.lxc_base_image
  unprivileged = true
  rootfs {
    storage = var.tailscale_storage
    size    = var.tailscale_storage_size
  }
  cores  = var.tailscale_cores
  memory = var.tailscale_memory
  network {
    name   = "eth0"
    bridge = "vmbr0"
    gw     = var.gateway_ip_address
    ip     = "${var.tailscale_ip_address}${var.netmask}"
  }
  ssh_public_keys = var.ssh_public_key
  onboot          = true
  start           = true

  provisioner "local-exec" {
    command = "ansible-playbook -i ${var.ansible_inventory} ${var.ansible_playbooks.tailscale} --vault-password-file .vault_pass.txt"
  }

  lifecycle {
    ignore_changes = [
      description,
    ]
  }
}

##### Nginx
resource "proxmox_lxc" "nginx" {
  target_node  = var.nginx_node
  vmid         = var.nginx_vm_id
  hostname     = var.nginx_hostname
  ostemplate   = var.lxc_base_image
  unprivileged = true
  rootfs {
    storage = var.nginx_storage
    size    = var.nginx_storage_size
  }
  cores  = var.nginx_cores
  memory = var.nginx_memory
  network {
    name   = "eth0"
    bridge = "vmbr0"
    gw     = var.gateway_ip_address
    ip     = "${var.nginx_ip_address}${var.netmask}"
  }
  ssh_public_keys = var.ssh_public_key
  onboot          = true
  start           = true

  provisioner "local-exec" {
    command = "ansible-playbook -i ${var.ansible_inventory} ${var.ansible_playbooks.nginx} --vault-password-file .vault_pass.txt"
  }
}
