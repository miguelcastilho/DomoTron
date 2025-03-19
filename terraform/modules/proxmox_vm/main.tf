variable "target_node" {
  description = "Proxmox node to deploy the VM on"
  type        = string
}

variable "vmid" {
  description = "VM ID in Proxmox"
  type        = number
}

variable "name" {
  description = "Name/hostname of the VM"
  type        = string
}

variable "clone" {
  description = "Template to clone"
  type        = string
}

variable "storage" {
  description = "Storage for the VM"
  type        = string
}

variable "storage_size" {
  description = "Storage size for the VM"
  type        = number
}

variable "cores" {
  description = "Number of CPU cores"
  type        = number
}

variable "sockets" {
  description = "Number of CPU sockets"
  type        = number
  default     = 1
}

variable "memory" {
  description = "Memory size in MB"
  type        = number
}

variable "ip_address" {
  description = "IP address to assign to the VM"
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
  description = "SSH public key for cloud-init"
  type        = string
}

# variable "additional_wait" {
#   description = "Additional wait time in seconds before running Ansible"
#   type        = number
#   default     = 60
# }

variable "bios" {
  description = "VM BIOS type"
  type        = string
  default     = "seabios"
}

variable "machine" {
  description = "VM machine type"
  type        = string
  default     = "q35"
}

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

variable "ansible_requirements" {
  description = "Path to the Ansible requirements file"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to the VM"
  type        = map(string)
  default     = {}
}

variable "dependencies" {
  description = "List of resources this VM depends on"
  type        = list(any)
  default     = []
}

resource "proxmox_vm_qemu" "vm" {
  target_node             = var.target_node
  vmid                    = var.vmid
  name                    = var.name
  clone                   = var.clone
  agent                   = 1
  os_type                 = "cloud-init"
  bios                    = var.bios
  machine                 = var.machine
  cloudinit_cdrom_storage = var.storage
  cores                   = var.cores
  sockets                 = var.sockets
  cpu                     = "host"
  numa                    = false
  memory                  = var.memory
  balloon                 = var.memory
  scsihw                  = "virtio-scsi-pci"
  bootdisk                = "scsi0"
  onboot                  = true
  full_clone              = false
  
  disks {
    scsi {
      scsi0 {
        disk {
          size    = var.storage_size
          storage = var.storage
          backup  = true
          discard = true
        }
      }
    }
  }
  
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }
  
  ipconfig0 = "ip=${var.ip_address}${var.netmask},gw=${var.gateway}"
  sshkeys   = var.ssh_public_key
  
  # Add tags as description
  description = join(",", [for key, value in var.tags : "${key}=${value}"])
  
  # Wait for VM to be ready before continuing
  # provisioner "local-exec" {
  #   command = "sleep ${var.additional_wait}"
  # }
  
  # Run Ansible if a playbook is specified
  provisioner "local-exec" {
    command = var.ansible_playbook != "" ? "ansible-playbook -i ${var.ansible_inventory} ${var.ansible_playbook}" : "echo 'No Ansible playbook specified, skipping...'"
  }
  
  # lifecycle {
  #   ignore_changes = [
  #     qemu_os,
  #     disks,
  #   ]
  # }
  
  dynamic "depends_on" {
    for_each = length(var.dependencies) > 0 ? [1] : []
    content {
      dependencies = var.dependencies
    }
  }
}

output "vm_ip" {
  description = "The IP address of the VM"
  value       = var.ip_address
}

output "vm_id" {
  description = "The ID of the VM"
  value       = var.vmid
}

output "vm_name" {
  description = "The name of the VM"
  value       = var.name
}