locals {
    tailscale_key_reusable = true
    tailscale_key_ephemeral = true
    tailscale_key_preauthorized = true
    tailscale_key_recreate_if_invalid = "always"
    cloudflare_tunnel_secret_random_byte_length = 64
    cloudflare_cname_records_name = {
        jellyseerr = "jellyseerr"
        jellyfin   = "jellyfin"
        homeassistant = "homeassistant"
    }
    cloudflare_cname_type = "CNAME"
    cloudflare_cname_proxied = true
    ansible_inventory  = "../ansible/inventory/hosts.yml"
    ansible_requirements = "../ansible/requirements.yml"
    ansible_tf_vars_file = "../ansible/tf_ansible_vars.yml"
    ansible_playbooks = {
        adguard   = "../ansible/adguard.yml"
        mediabox  = "../ansible/mediabox.yml"
        tailscale = "../ansible/tailscale.yml"
        nginx     = "../ansible/nginx_proxy_manager.yml"
        proxmox   = "../ansible/proxmox.yml"
    }
}