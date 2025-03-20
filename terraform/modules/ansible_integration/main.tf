variable "project_root" {
  description = "Path to the project root directory"
  type        = string
}

variable "vault_password_file" {
  description = "Path to the Ansible vault password file"
  type        = string
  default     = ".vault_password"
}

variable "sensitive_variables" {
  description = "Map of sensitive variables to encrypt"
  type        = map(string)
  sensitive   = true
  default     = {}
}

variable "non_sensitive_variables" {
  description = "Map of non-sensitive variables"
  type        = map(string)
  default     = {}
}

variable "output_file" {
  description = "Path to the output variables file (relative to project root)"
  type        = string
  default     = "ansible/tf_ansible_vars.yml"
}

variable "dependencies" {
  description = "List of resources this integration depends on"
  type        = list(any)
  default     = []
}

# Create the ansible.cfg file
resource "local_file" "ansible_config" {
  content = <<-EOT
    [defaults]
    inventory = ${var.project_root}/ansible/terraform_inventory.sh
    vault_password_file = ${var.project_root}/${var.vault_password_file}
    host_key_checking = False
    roles_path = ${var.project_root}/ansible/roles
    retry_files_enabled = False
    force_color = True
    stdout_callback = yaml

    # Parallelism settings
    forks = 10
       
    [ssh_connection]
    pipelining = True
    ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o StrictHostKeyChecking=no

    [diff]
    always = True
    context = 3
  EOT
  filename        = "${var.project_root}/ansible.cfg"
  file_permission = "0644"
}

# Create a template file for variables
resource "local_file" "variables_template" {
  content = templatefile("${path.module}/templates/variables.yml.tpl", {
    sensitive_vars     = var.sensitive_variables
    non_sensitive_vars = var.non_sensitive_variables
  })
  filename        = "${var.project_root}/${var.output_file}"
  file_permission = "0644"
  
  depends_on = [
    local_file.ansible_config,
    var.dependencies
  ]
  
  # Encrypt the variables file if it contains sensitive data
  provisioner "local-exec" {
    command = length(var.sensitive_variables) > 0 ? "cd ${var.project_root}/ansible && ansible-vault encrypt tf_ansible_vars.yml" : "echo 'No sensitive variables to encrypt'"
  }
}

output "ansible_variables_file" {
  description = "Path to the generated Ansible variables file"
  value       = "${var.project_root}/${var.output_file}"
}