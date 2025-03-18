---
# Ansible vars_file containing variable values from Terraform.
# Non-sensitive variables
tf_cf_tunnel_id: ${cf_tunnel_id}
tf_cf_account_id: ${cf_account_id}
tf_cf_tunnel_name: ${cf_tunnel_name}
tf_mediabox_ip_address: ${mediabox_ip_address}

# Sensitive variables - these will be encrypted by Ansible Vault
# during the template rendering process
tf_cf_tunnel_secret: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          ${cf_tunnel_secret}
tf_cf_token: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          ${cf_token}
tf_tailscale_authkey: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          ${tailscale_authkey}