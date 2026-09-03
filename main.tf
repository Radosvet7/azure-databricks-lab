terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "lab" {
  name     = "rg-databricks-lab"
  location = "North Europe"
}

resource "azurerm_virtual_network" "databricks" {
  name                = "vnet-databricks-lab"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "databricks_public" {
  name                 = "snet-databricks-public"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.databricks.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "databricks_private" {
  name                 = "snet-databricks-private"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.databricks.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_databricks_workspace" "lab" {
  name                = "dbw-databricks-lab"
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location
  sku                 = "premium"
}

resource "azurerm_storage_account" "datalake" {
  name                     = "n5go3xx3fvzohb1b51cf"
  resource_group_name      = azurerm_resource_group.lab.name
  location                 = azurerm_resource_group.lab.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  is_hns_enabled = true
}

locals {
  containers = toset([
    "unity-catalog",
    "data"
  ])
}

resource "azurerm_storage_container" "datalake" {
  for_each = local.containers

  name               = each.value
  storage_account_id = azurerm_storage_account.datalake.id
}

resource "azurerm_databricks_access_connector" "unity_catalog" {
  name                = "ac-databricks-lab"
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "datalake" {
  scope                = azurerm_storage_account.datalake.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_databricks_access_connector.unity_catalog.identity[0].principal_id
}