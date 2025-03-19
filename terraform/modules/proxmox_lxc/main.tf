variable "target_node" {
  description = "Proxmox node to deploy the LXC on"
  type        = string
}

variable "vmid" {
  description = "LXC ID in Proxmox"
  type        = number
}

variable "hostname" {
  description = "Hostname of the LXC"
  type        = string
}

variable "ostemplate" {
  description = "OS template to use"
  type        = string
}

variable "storage" {
  description = "Storage for the LXC"
  type        = string
}

variable "storage_size" {
  description = "Storage size for the LXC (e.g. '8G')"
  type        = string
}

variable "cores" {
  description = "Number of CPU cores"
  type        = number
}

variable "memory" {
  description = "Memory size in MB"
  type        = number
}

variable "ip_address" {
  description = "IP address to assign to the LXC"
  type        = string
}

variable "gateway" {
  description = "Default gateway"
  type        = string
}

variable "netmask" {
  description = "Network mask"
  type        = string
  default     = "/24"
}

variable "ssh_public_key" {
  description = "SSH public key for LXC access"
  type        = string
}

variable "unprivileged" {
  description = "Create unprivileged container"
  type        = bool
  default     = true
}

variable "start" {
  description = "Start container after creation"
  type        = bool
  default     = true
}

variable "onboot" {
  description = "Start container on boot"
  type        = bool
  default     = true
}

# variable "additional_wait" {
#   description = "Additional wait time in seconds before running Ansible"
#   type        = number
#   default     = 30
# }

variable "ansible_playbook" {
  description = "Path to the Ansible playbook to run"
  type        = string
  default     = ""
}

variable "ansible_inventory" {
  description = "Path to the Ansible inventory"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to the LXC"
  type        = map(string)
  default     = {}
}

variable "dependencies" {
  description = "List of resources this LXC depends on"
  type        = list(any)
  default     = []
}

resource "proxmox_lxc" "lxc" {
  target_node  = var.target_node
  vmid         = var.vmid
  hostname     = var.hostname
  ostemplate   = var.ostemplate
  unprivileged = var.unprivileged
  
  rootfs {
    storage = var.storage
    size    = var.storage_size
  }
  
  cores  = var.cores
  memory = var.memory
  
  network {
    name   = "eth0"
    bridge = "vmbr0"
    gw     = var.gateway
    ip     = "${var.ip_address}${var.netmask}"
  }
  
  ssh_public_keys = var.ssh_public_key
  onboot          = var.onboot
  start           = var.start
  
  # Add tags as description
  description = join(",", [for key, value in var.tags : "${key}=${value}"])
  
  # Wait for LXC to be ready before continuing
  # provisioner "local-exec" {
  #   command = "sleep ${var.additional_wait}"
  # }
  
  # Run Ansible if a playbook is specified
  provisioner "local-exec" {
    command = var.ansible_playbook != "" ? "ansible-playbook -i ${var.ansible_inventory} ${var.ansible_playbook}" : "echo 'No Ansible playbook specified, skipping...'"
  }
  
  # lifecycle {
  #   ignore_changes = [
  #     description,
  #   ]
  # }
  
  depends_on = var.dependencies
}

output "lxc_ip" {
  description = "The IP address of the LXC"
  value       = var.ip_address
}

output "lxc_id" {
  description = "The ID of the LXC"
  value       = var.vmid
}

output "lxc_hostname" {
  description = "The hostname of the LXC"
  value       = var.hostname
}