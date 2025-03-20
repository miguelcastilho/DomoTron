.PHONY: init plan apply provision clean validate help setup env-check ansible-config

# Colors
GREEN = \033[0;32m
YELLOW = \033[1;33m
RED = \033[0;31m
NC = \033[0m # No Color

# Default target
.DEFAULT_GOAL := help

# Check if vault password file and ansible.cfg exist
env-check:
	@if [ ! -f terraform/.vault_password ]; then \
		printf "$(RED)Error: terraform/.vault_password not found. Run 'make setup' first.$(NC)\n"; \
		exit 1; \
	fi
	@if [ ! -f terraform/ansible.cfg ]; then \
		printf "$(RED)Error: ansible.cfg not found. Run 'make setup' first.$(NC)\n"; \
		exit 1; \
	fi

# Create ansible.cfg
ansible-config:
	@printf "$(YELLOW)Creating terraform/ansible.cfg...$(NC)\n"
	@echo "[defaults]" > $(shell pwd)/terraform/ansible.cfg
	@echo "inventory = $(shell pwd)/ansible/terraform_inventory.sh" >> terraform/ansible.cfg
	@echo "vault_password_file = $(shell pwd)/terraform/.vault_password" >> terraform/ansible.cfg
	@echo "host_key_checking = False" >> terraform/ansible.cfg
	@echo "roles_path = $(shell pwd)/ansible/roles" >> terraform/ansible.cfg
	@echo "retry_files_enabled = False" >> terraform/ansible.cfg
	@echo "force_color = True" >> terraform/ansible.cfg
	@echo "stdout_callback = yaml" >> terraform/ansible.cfg
	@echo "" >> terraform/ansible.cfg
	@echo "# Parallelism settings" >> terraform/ansible.cfg
	@echo "forks = 10" >> terraform/ansible.cfg
	@echo "" >> terraform/ansible.cfg
	@echo "[ssh_connection]" >> terraform/ansible.cfg
	@echo "pipelining = False" >> terraform/ansible.cfg
	@echo "ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o StrictHostKeyChecking=no" >> terraform/ansible.cfg
	@echo "" >> terraform/ansible.cfg
	@echo "[diff]" >> terraform/ansible.cfg
	@echo "always = True" >> terraform/ansible.cfg
	@echo "context = 3" >> terraform/ansible.cfg
	@chmod 644 terraform/ansible.cfg
	@printf "$(GREEN)File terraform/ansible.cfg created!$(NC)\n"

# Initial setup
setup:
	@printf "$(YELLOW)Creating vault password file...$(NC)\n"
	@if [ ! -f terraform/.vault_password ]; then \
		printf "Please enter a strong password for Ansible Vault encryption (press Enter to auto-generate):\n"; \
		read -s VAULT_PASS; \
		if [ -z "$$VAULT_PASS" ]; then \
			printf "$(YELLOW)Generating a secure random password...$(NC)\n"; \
			if command -v openssl &> /dev/null; then \
				VAULT_PASS=$$(openssl rand -base64 24); \
			else \
				VAULT_PASS=$$(cat /dev/urandom | LC_ALL=C tr -dc 'a-zA-Z0-9!@#$%^&*()_+?><~' | head -c 32); \
			fi; \
			printf "$(GREEN)Secure password generated!$(NC)\n"; \
			printf "$(YELLOW)Important: This password will not be shown again. It is securely stored in terraform/.vault_password$(NC)\n"; \
		fi; \
		echo "$$VAULT_PASS" > terraform/.vault_password; \
		chmod 600 terraform/.vault_password; \
		printf "$(GREEN)Vault password file created!$(NC)\n"; \
	else \
		printf "$(GREEN)Vault password file already exists.$(NC)\n"; \
	fi
	@$(MAKE) ansible-config
	@printf "$(GREEN)\nSetup completed successfully!$(NC)\n"

# Terraform commands
init: env-check
	@printf "$(YELLOW)Initializing Terraform...$(NC)\n"
	cd terraform && terraform init

plan: env-check init
	@printf "$(YELLOW)Creating Terraform plan...$(NC)\n"
	cd terraform && terraform plan -out=tfplan

apply: env-check plan
	@printf "$(YELLOW)Applying Terraform changes...$(NC)\n"
	cd terraform && terraform apply tfplan

# Ansible commands
ansible-requirements: env-check
	@printf "$(YELLOW)Installing Ansible requirements...$(NC)\n"
	ansible-galaxy collection install -r ansible/requirements.yml

provision: env-check
	@printf "$(YELLOW)Provisioning infrastructure with Ansible...$(NC)\n"
	cd ansible && ansible-playbook -i terraform_inventory.sh site.yml

provision-adguard: env-check
	@printf "$(YELLOW)Provisioning AdGuard...$(NC)\n"
	cd ansible && ansible-playbook -i terraform_inventory.sh adguard.yml

provision-mediabox: env-check
	@printf "$(YELLOW)Provisioning MediaBox...$(NC)\n"
	cd ansible && ansible-playbook -i terraform_inventory.sh mediabox.yml

provision-nginx: env-check
	@printf "$(YELLOW)Provisioning Nginx Proxy Manager...$(NC)\n"
	cd ansible && ansible-playbook -i terraform_inventory.sh nginx_proxy_manager.yml

provision-tailscale: env-check
	@printf "$(YELLOW)Provisioning Tailscale...$(NC)\n"
	cd ansible && ansible-playbook -i terraform_inventory.sh tailscale.yml

# Validation
validate: env-check
	@printf "$(YELLOW)Validating Terraform configuration...$(NC)\n"
	cd terraform && terraform validate
	@printf "$(YELLOW)Validating Ansible playbooks...$(NC)\n"
	ansible-playbook -i ansible/terraform_inventory.sh --syntax-check ansible/site.yml ansible/adguard.yml ansible/mediabox.yml ansible/nginx_proxy_manager.yml ansible/tailscale.yml ansible/proxmox.yml ansible/update.yml

# Clean up
clean:
	@printf "$(YELLOW)Cleaning up...$(NC)\n"
	rm -f terraform/tfplan
	find . -name "*.retry" -delete
	@printf "$(GREEN)Clean up completed!$(NC)\n"

# Full deployment
deploy: env-check init apply
	@printf "$(GREEN)Deployment completed successfully!$(NC)\n"

# Help
help:
	@printf "$(GREEN)DomoTron Makefile Commands:$(NC)\n"
	@printf "  $(YELLOW)%-24s$(NC) - %s\n" "setup" "Initial setup (vault password, ansible.cfg)"
	@printf "  $(YELLOW)%-24s$(NC) - %s\n" "init" "Initialize Terraform"
	@printf "  $(YELLOW)%-24s$(NC) - %s\n" "plan" "Create Terraform execution plan"
	@printf "  $(YELLOW)%-24s$(NC) - %s\n" "apply" "Apply Terraform changes"
	@printf "  $(YELLOW)%-24s$(NC) - %s\n" "ansible-config" "Create ansible.cfg file"
	@printf "  $(YELLOW)%-24s$(NC) - %s\n" "ansible-requirements" "Install Ansible requirements"
	@printf "  $(YELLOW)%-24s$(NC) - %s\n" "provision" "Run all Ansible playbooks"
	@printf "  $(YELLOW)%-24s$(NC) - %s\n" "provision-adguard" "Run AdGuard playbook"
	@printf "  $(YELLOW)%-24s$(NC) - %s\n" "provision-mediabox" "Run MediaBox playbook"
	@printf "  $(YELLOW)%-24s$(NC) - %s\n" "provision-nginx" "Run Nginx Proxy Manager playbook"
	@printf "  $(YELLOW)%-24s$(NC) - %s\n" "provision-tailscale" "Run Tailscale playbook"
	@printf "  $(YELLOW)%-24s$(NC) - %s\n" "validate" "Validate Terraform and Ansible configurations"
	@printf "  $(YELLOW)%-24s$(NC) - %s\n" "clean" "Clean up generated files"
	@printf "  $(YELLOW)%-24s$(NC) - %s\n" "deploy" "Complete deployment"
	@printf "  $(YELLOW)%-24s$(NC) - %s\n" "help" "Show this help message"
