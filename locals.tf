locals {
  environments = {
    dev = {
      resource_group_name = "rg-databricks-dev"
      location            = "North Europe"

      vnet_name          = "vnet-databricks-dev"
      vnet_address_space = ["10.0.0.0/16"]

      public_subnet_name     = "snet-databricks-public-dev"
      public_subnet_prefixes = ["10.0.1.0/24"]

      private_subnet_name     = "snet-databricks-private-dev"
      private_subnet_prefixes = ["10.0.2.0/24"]
    }

    prod = {
      resource_group_name = "rg-databricks-prod"
      location            = "North Europe"

      vnet_name          = "vnet-databricks-prod"
      vnet_address_space = ["10.1.0.0/16"]

      public_subnet_name     = "snet-databricks-public-prod"
      public_subnet_prefixes = ["10.1.1.0/24"]

      private_subnet_name     = "snet-databricks-private-prod"
      private_subnet_prefixes = ["10.1.2.0/24"]
    }
  }
}