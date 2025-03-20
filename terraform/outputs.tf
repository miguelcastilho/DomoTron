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
    nginx = {
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

output "mediabox" {
  description = "MediaBox VM details"
  value       = module.mediabox
}

output "adguard" {
  description = "AdGuard LXC details"
  value       = module.adguard
}

output "tailscale" {
  description = "Tailscale LXC details"
  value       = module.tailscale
}

output "nginx" {
  description = "Nginx Proxy Manager LXC details"
  value       = module.nginx
}

output "ansible_variables_file" {
  description = "Path to Ansible variables file"
  value       = "${path.module}/../ansible/tf_ansible_vars.yml"
}

output "sensitive_values_stored_in" {
  description = "Information about where sensitive values are stored"
  value       = "Sensitive values are encrypted in ansible/tf_ansible_vars.yml using Ansible Vault"
}