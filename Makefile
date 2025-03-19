.PHONY: init plan apply provision clean validate test help setup env-check

# Colors
GREEN = \033[0;32m
YELLOW = \033[1;33m
RED = \033[0;31m
NC = \033[0m # No Color

# Default target
.DEFAULT_GOAL := help

# Check if vault password file exists
env-check:
	@if [ ! -f .vault_pass.txt ]; then \
		echo -e "$(RED)Error: .vault_pass.txt not found. Run 'make setup' first.$(NC)"; \
		exit 1; \
	fi

# Initial setup
setup:
	@echo -e "$(YELLOW)Creating vault password file...$(NC)"
	@if [ ! -f .vault_pass.txt ]; then \
		echo "Please enter a strong password for Ansible Vault encryption (press Enter to auto-generate):"; \
		read -s VAULT_PASS; \
		if [ -z "$$VAULT_PASS" ]; then \
			echo -e "$(YELLOW)Generating a secure random password...$(NC)"; \
			if command -v openssl &> /dev/null; then \
				VAULT_PASS=$$(openssl rand -base64 24); \
			else \
				VAULT_PASS=$$(cat /dev/urandom | LC_ALL=C tr -dc 'a-zA-Z0-9!@#$%^&*()_+?><~' | head -c 32); \
			fi; \
			echo -e "$(GREEN)Secure password generated!$(NC)"; \
			echo -e "$(YELLOW)Important: This password will not be shown again. It is securely stored in .vault_pass.txt$(NC)"; \
		fi; \
		echo "$$VAULT_PASS" > .vault_pass.txt; \
		chmod 600 .vault_pass.txt; \
		echo -e "$(GREEN)Vault password file created!$(NC)"; \
	else \
		echo -e "$(YELLOW)Vault password file already exists.$(NC)"; \
	fi
	@echo -e "$(GREEN)Creating ansible.cfg from template...$(NC)"
	@cp ansible/ansible.cfg.template ansible.cfg
	@sed -i '' "s|vault_password_file = ../.vault_pass.txt|vault_password_file = $(shell pwd)/.vault_pass.txt|g" ansible.cfg
	@chmod 644 ansible.cfg
	@echo -e "$(GREEN)Setup completed successfully!$(NC)"

# Terraform commands
init: env-check
	@echo -e "$(YELLOW)Initializing Terraform...$(NC)"
	cd terraform && terraform init

plan: env-check init
	@echo -e "$(YELLOW)Creating Terraform plan...$(NC)"
	cd terraform && terraform plan -out=tfplan

apply: env-check plan
	@echo -e "$(YELLOW)Applying Terraform changes...$(NC)"
	cd terraform && terraform apply tfplan

# Ansible commands
ansible-requirements: env-check
	@echo -e "$(YELLOW)Installing Ansible requirements...$(NC)"
	ansible-galaxy collection install -r ansible/requirements.yml

provision: env-check
	@echo -e "$(YELLOW)Provisioning infrastructure with Ansible...$(NC)"
	cd ansible && ansible-playbook -i inventory/hosts.yml site.yml

provision-adguard: env-check
	@echo -e "$(YELLOW)Provisioning AdGuard...$(NC)"
	cd ansible && ansible-playbook -i inventory/hosts.yml adguard.yml

provision-mediabox: env-check
	@echo -e "$(YELLOW)Provisioning MediaBox...$(NC)"
	cd ansible && ansible-playbook -i inventory/hosts.yml mediabox.yml

provision-nginx: env-check
	@echo -e "$(YELLOW)Provisioning Nginx Proxy Manager...$(NC)"
	cd ansible && ansible-playbook -i inventory/hosts.yml nginx_proxy_manager.yml

provision-tailscale: env-check
	@echo -e "$(YELLOW)Provisioning Tailscale...$(NC)"
	cd ansible && ansible-playbook -i inventory/hosts.yml tailscale.yml

# Validation
validate: env-check
	@echo -e "$(YELLOW)Validating Terraform configuration...$(NC)"
	cd terraform && terraform validate
	@echo -e "$(YELLOW)Validating Ansible playbooks...$(NC)"
	cd ansible && ansible-playbook -i inventory/hosts.yml --syntax-check site.yml adguard.yml mediabox.yml nginx_proxy_manager.yml tailscale.yml proxmox.yml update.yml

# Testing
test: env-check validate
	@echo -e "$(YELLOW)Running tests...$(NC)"
	@echo -e "$(GREEN)All tests passed!$(NC)"

# Clean up
clean:
	@echo -e "$(YELLOW)Cleaning up...$(NC)"
	rm -f terraform/tfplan
	find . -name "*.retry" -delete
	@echo -e "$(GREEN)Clean up completed!$(NC)"

# Full deployment
deploy: env-check init apply
	@echo -e "$(GREEN)Deployment completed successfully!$(NC)"

# Help
help:
	@echo -e "$(GREEN)DomoTron Makefile Commands:$(NC)"
	@echo -e "  $(YELLOW)setup$(NC)              - Initial setup (vault password, ansible.cfg)"
	@echo -e "  $(YELLOW)init$(NC)               - Initialize Terraform"
	@echo -e "  $(YELLOW)plan$(NC)               - Create Terraform execution plan"
	@echo -e "  $(YELLOW)apply$(NC)              - Apply Terraform changes"
	@echo -e "  $(YELLOW)ansible-requirements$(NC) - Install Ansible requirements"
	@echo -e "  $(YELLOW)provision$(NC)          - Run all Ansible playbooks"
	@echo -e "  $(YELLOW)provision-adguard$(NC)  - Run AdGuard playbook"
	@echo -e "  $(YELLOW)provision-mediabox$(NC) - Run MediaBox playbook"
	@echo -e "  $(YELLOW)provision-nginx$(NC)    - Run Nginx Proxy Manager playbook"
	@echo -e "  $(YELLOW)provision-tailscale$(NC) - Run Tailscale playbook"
	@echo -e "  $(YELLOW)validate$(NC)           - Validate Terraform and Ansible configurations"
	@echo -e "  $(YELLOW)test$(NC)               - Run tests"
	@echo -e "  $(YELLOW)clean$(NC)              - Clean up generated files"
	@echo -e "  $(YELLOW)deploy$(NC)             - Complete deployment"
	@echo -e "  $(YELLOW)help$(NC)               - Show this help message"