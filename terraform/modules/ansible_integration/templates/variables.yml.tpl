---
# Ansible vars_file containing variable values from Terraform.
# This file is generated automatically, do not edit manually.
# Generated: ${timestamp()}

# Non-sensitive variables
%{ for key, value in non_sensitive_vars ~}
tf_${key}: ${value}
%{ endfor ~}

# Sensitive variables - these will be encrypted by Ansible Vault
%{ for key, value in sensitive_vars ~}
tf_${key}: ${value}
%{ endfor ~}