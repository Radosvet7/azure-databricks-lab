terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }

    random = {
      source = "hashicorp/random"
    }

    databricks = {
      source = "databricks/databricks"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "databricks" {
  alias = "dev"
  host  = module.databricks_ws["dev"].workspace_url
}

provider "databricks" {
  alias = "prod"
  host  = module.databricks_ws["prod"].workspace_url
}

provider "databricks" {
  alias           = "account"
  host            = "https://accounts.azuredatabricks.net"
  account_id      = var.databricks_account_id
  auth_type       = "azure-cli"
  azure_tenant_id = var.azure_tenant_id
}