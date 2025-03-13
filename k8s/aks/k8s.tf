terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.23.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# set this value via env variable: TF_VAR_env
variable "env" {
  type        = string
  description = "common resource tag. e.g. dev, test, prod"
}

# set this value via env variable: TF_VAR_vmtype
variable "vmtype" {
  type        = string
  description = "Azure VM size/type name.  e.g. Standard_B2s"
}

# set this value via env variable: TF_VAR_maxsize and TF_VAR_minsize
variable "minsize" {
  type        = number
  description = "minimum number of VM instaces"
}
variable "maxsize" {
  type        = number
  description = "maximum number of VM instaces"
}

resource "random_string" "postfix" {
  length  = 6
  special = false
  upper   = false
  numeric = false
}

locals {
  common_tags = {
    env            = var.env
    app            = "home"
    terraform_repo = "unknown"
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "home-resources-${random_string.postfix.result}"
  location = "Japan East"
  tags     = local.common_tags
}

resource "azurerm_kubernetes_cluster" "homeaks" {
  name                = "home-aks-${random_string.postfix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "homeaks-${random_string.postfix.result}"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = var.vmtype
  }
  # linux_profile {
  #   admin_username = "azureuser"

  #   ssh_key {
  #     key_data = "${file("~/.ssh/id_rsa.pub")}"
  #   }
  # }
  identity {
    type = "SystemAssigned"
  }
  http_application_routing_enabled = false
  tags = local.common_tags
}

resource "azurerm_kubernetes_cluster_node_pool" "workers" {
  name                  = "workers"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.homeaks.id
  vm_size               = var.vmtype
  enable_auto_scaling   = true
  min_count             = var.minsize
  max_count             = var.maxsize
  node_labels = {
    "kind" = "workers"
  }
  tags = local.common_tags
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.homeaks.kube_config_raw
  sensitive = true
}

# NSG等の内部リソースが別グループで自動作成される。そのグループ名
output "name_nrg" {
  value = azurerm_kubernetes_cluster.homeaks.node_resource_group
}
