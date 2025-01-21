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
    tailscale_tailnet_key.tailscale_key
  ]
}
