#!/bin/bash

# Variables
SERVER_IP="192.168.1.99"
IMAGE_URL="https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
FILE_NAME="noble-server-cloudimg-amd64.img"
IMAGE_NAME="ubuntu-24.04-lts"
STORAGE="vms"
VM_ID=9000

# shellcheck disable=SC2087
ssh root@"$SERVER_IP" <<EOF
    set -e  # Exit immediately if a command exits with a non-zero status

    # Cleanup old image and VM
    rm -f "$FILE_NAME" || true  # Ignore error if file doesn't exist
    qm destroy $VM_ID || true  # Ignore error if VM doesn't exist

    # Download new image
    wget "$IMAGE_URL" -O "$FILE_NAME"

    # Update package manager and install guestfs-tools
    apt update
    apt install -y guestfs-tools

    # Customize the image
    virt-customize -a "$FILE_NAME" \\
      --install qemu-guest-agent \\
      --run-command 'systemctl start qemu-guest-agent.service && systemctl enable qemu-guest-agent.service'
    virt-customize -a "$FILE_NAME" --truncate /etc/machine-id

    # Create and configure the VM
    qm create $VM_ID --name "$IMAGE_NAME" --memory 2048 --cores 1 \\
      --net0 virtio,bridge=vmbr0 --scsihw virtio-scsi-pci
    qm importdisk $VM_ID "$FILE_NAME" "$STORAGE"
    qm set $VM_ID --scsihw virtio-scsi-pci --scsi0 "$STORAGE":vm-$VM_ID-disk-0
    qm set $VM_ID --ide2 "$STORAGE":cloudinit
    qm set $VM_ID --boot c --bootdisk scsi0
    qm set $VM_ID --serial0 socket --vga serial0
    qm set $VM_ID --agent enabled=1
    qm template $VM_ID

    # Cleanup
    rm -f "$FILE_NAME"
EOF
