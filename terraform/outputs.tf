output "servers" {
  description = "Details of all server instances"
  value = {
    mediabox = {
      ip       = var.mediabox_ip_address
      hostname = var.mediabox_hostname
      roles    = ["media_server", "apps"]
    }
    adguard = {
      ip       = var.adguard_ip_address
      hostname = var.adguard_hostname
      roles    = ["dns", "adguard"]
    }
    tailscale = {
      ip       = var.tailscale_ip_address
      hostname = var.tailscale_hostname
      roles    = ["network", "tailscale"]
    }
    nginx_proxy_manager = {
      ip       = var.nginx_ip_address
      hostname = var.nginx_hostname
      roles    = ["proxy", "nginx"]
    }
  }
}

output "cloudflare" {
  description = "Cloudflare configuration details"
  value = {
    tunnel_id   = cloudflare_zero_trust_tunnel_cloudflared.mediabox.id
    account_id  = var.cloudflare_account_id
    tunnel_name = cloudflare_zero_trust_tunnel_cloudflared.mediabox.name
  }
  sensitive = true
}

output "sensitive_values_stored_in" {
  description = "Information about where sensitive values are stored"
  value       = "Sensitive values are encrypted in ansible/tf_ansible_vars.yml using Ansible Vault"
}