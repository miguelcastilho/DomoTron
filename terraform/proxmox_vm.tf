##### Mediabox
resource "proxmox_vm_qemu" "mediabox" {
  target_node             = var.mediabox_node
  vmid                    = var.mediabox_vm_id
  name                    = var.mediabox_hostname
  clone                   = var.mediabox_vm_base_image
  agent                   = 1
  os_type                 = "cloud-init"
  bios                    = var.mediabox_bios
  machine                 = var.mediabox_machine_type
  cloudinit_cdrom_storage = var.mediabox_storage
  cores                   = var.mediabox_cores
  sockets                 = var.mediabox_sockets
  cpu                     = "host"
  numa                    = false
  memory                  = var.mediabox_memory
  balloon                 = var.mediabox_memory
  scsihw                  = "virtio-scsi-pci"
  bootdisk                = "scsi0"
  onboot                  = true
  full_clone              = false
  disks {
    scsi {
      scsi0 {
        disk {
          size    = var.mediabox_storage_size
          storage = var.mediabox_storage
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
  ipconfig0 = "ip=${var.mediabox_ip_address}${var.netmask},gw=${var.gateway_ip_address}"
  sshkeys   = var.ssh_public_key

  provisioner "local-exec" {
    command = "ansible-galaxy install -r ${var.ansible_requirements}"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ${var.ansible_inventory} ${var.ansible_playbooks.mediabox} --vault-password-file .vault_pass.txt"
  }

  lifecycle {
    ignore_changes = [
      qemu_os,
      disks,
    ]
  }
}



