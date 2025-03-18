resource "random_id" "ansible_vault_id" {
  byte_length = 8
}

# This resource creates a secure config for Ansible execution
resource "local_file" "ansible_vault_config" {
  content = <<-EOT
    [defaults]
    vault_password_file = ${abspath(path.module)}/../.vault_pass.txt
    host_key_checking = False
    
    [vault]
    id = terraform-${random_id.ansible_vault_id.hex}
    
    [ssh_connection]
    pipelining = True
  EOT
  filename        = "../ansible/ansible.cfg"
  file_permission = "0644"
}

# Generate tf_ansible_vars.yml with properly structured and sensitive variables
resource "local_file" "tf_ansible_vars" {
  content = templatefile("${path.module}/templates/tf_ansible_vars.yml.tpl", {
    cf_tunnel_id        = cloudflare_zero_trust_tunnel_cloudflared.mediabox.id
    cf_account_id       = var.cloudflare_account_id
    cf_tunnel_name      = cloudflare_zero_trust_tunnel_cloudflared.mediabox.name
    cf_tunnel_secret    = random_id.tunnel_secret.b64_std
    cf_token            = var.cloudflare_token
    tailscale_authkey   = tailscale_tailnet_key.tailscale_key.key
    mediabox_ip_address = var.mediabox_ip_address
  })

  filename = "../ansible/tf_ansible_vars.yml"

  depends_on = [
    tailscale_tailnet_key.tailscale_key,
    cloudflare_zero_trust_tunnel_cloudflared.mediabox,
    random_id.tunnel_secret
  ]

  provisioner "local-exec" {
    # Using ansible.cfg for vault password file reference
    command = "cd ../ansible && ansible-vault encrypt tf_ansible_vars.yml"
  }
}