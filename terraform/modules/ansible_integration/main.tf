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

# Create a template file for variables
resource "local_file" "variables_template" {
  content = templatefile("${path.module}/templates/variables.yml.tpl", {
    sensitive_vars     = var.sensitive_variables
    non_sensitive_vars = var.non_sensitive_variables
  })
  filename        = "${var.project_root}/${var.output_file}"
  file_permission = "0644"
  
  # Dependencies are passed to the module and handled externally
  
  # Encrypt the variables file if it contains sensitive data
  provisioner "local-exec" {
    command = length(var.sensitive_variables) > 0 ? "ansible-vault encrypt ${var.project_root}/${var.output_file}" : "echo 'No sensitive variables to encrypt'"
  }
}

output "ansible_variables_file" {
  description = "Path to the generated Ansible variables file"
  value       = "${var.project_root}/${var.output_file}"
}