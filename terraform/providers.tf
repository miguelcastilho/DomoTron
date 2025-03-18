terraform {
  required_version = ">= 1.5.7"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.5.2"
    }
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc1"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.52.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.1"
    }
    ansible = {
      source  = "nbering/ansible"
      version = "1.0.4"
    }
    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.18.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.3"
    }
  }
}

provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
}

provider "cloudflare" {
  api_token = var.cloudflare_token
}

provider "tailscale" {
  api_key = var.tailscale_api_key
  tailnet = var.tailscale_tailnet
}