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