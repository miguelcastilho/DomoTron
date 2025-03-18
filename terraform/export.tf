resource "null_resource" "vault_encrypt_secrets" {
  provisioner "local-exec" {
    command = <<-EOT
      echo '${random_id.tunnel_secret.b64_std}' | ansible-vault encrypt_string --stdin-name 'cf_tunnel_secret' > ${path.module}/temp_tunnel_secret.txt
      echo '${var.cloudflare_token}' | ansible-vault encrypt_string --stdin-name 'cf_token' > ${path.module}/temp_cf_token.txt
      echo '${tailscale_tailnet_key.tailscale_key.key}' | ansible-vault encrypt_string --stdin-name 'tailscale_authkey' > ${path.module}/temp_tailscale_key.txt
    EOT
  }

  triggers = {
    tunnel_secret = random_id.tunnel_secret.b64_std
    tailscale_key = tailscale_tailnet_key.tailscale_key.key
  }
}

data "local_file" "encrypted_tunnel_secret" {
  filename = "${path.module}/temp_tunnel_secret.txt"
  depends_on = [null_resource.vault_encrypt_secrets]
}

data "local_file" "encrypted_cf_token" {
  filename = "${path.module}/temp_cf_token.txt"
  depends_on = [null_resource.vault_encrypt_secrets]
}

data "local_file" "encrypted_tailscale_key" {
  filename = "${path.module}/temp_tailscale_key.txt"
  depends_on = [null_resource.vault_encrypt_secrets]
}

resource "local_file" "tf_ansible_vars" {
  content = templatefile("${path.module}/templates/tf_ansible_vars.yml.tpl", {
    cf_tunnel_id        = cloudflare_zero_trust_tunnel_cloudflared.mediabox.id
    cf_account_id       = var.cloudflare_account_id
    cf_tunnel_name      = cloudflare_zero_trust_tunnel_cloudflared.mediabox.name
    cf_tunnel_secret    = trimspace(regex("\\$ANSIBLE_VAULT.*", data.local_file.encrypted_tunnel_secret.content))
    cf_token            = trimspace(regex("\\$ANSIBLE_VAULT.*", data.local_file.encrypted_cf_token.content))
    tailscale_authkey   = trimspace(regex("\\$ANSIBLE_VAULT.*", data.local_file.encrypted_tailscale_key.content))
    mediabox_ip_address = var.mediabox_ip_address
  })

  filename = "../ansible/tf_ansible_vars.yml"

  depends_on = [
    tailscale_tailnet_key.tailscale_key,
    cloudflare_zero_trust_tunnel_cloudflared.mediabox,
    random_id.tunnel_secret,
    null_resource.vault_encrypt_secrets,
    data.local_file.encrypted_tunnel_secret,
    data.local_file.encrypted_cf_token,
    data.local_file.encrypted_tailscale_key
  ]

  provisioner "local-exec" {
    command = "rm -f ${path.module}/temp_*.txt"
  }
}