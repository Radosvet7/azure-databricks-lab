module "resource_group" {
  source = "./modules/resource_group"

  for_each = local.environments

  name     = each.value.resource_group_name
  location = each.value.location
}

module "networking" {
  source = "./modules/networking"

  for_each = local.environments

  resource_group_name = module.resource_group[each.key].name
  location            = module.resource_group[each.key].location

  vnet_name          = each.value.vnet_name
  vnet_address_space = each.value.vnet_address_space

  public_subnet_name     = each.value.public_subnet_name
  public_subnet_prefixes = each.value.public_subnet_prefixes

  private_subnet_name     = each.value.private_subnet_name
  private_subnet_prefixes = each.value.private_subnet_prefixes
}

module "storage" {
  source = "./modules/storage"

  for_each = local.environments

  resource_group_name = module.resource_group[each.key].name
  location            = module.resource_group[each.key].location

  storage_account_name = "${each.key}dbx${random_string.storage_suffix[each.key].result}"

  containers = toset([
    "data",
    "unity-catalog"
  ])
}

module "databricks_ws" {
  source = "./modules/databricks_ws"

  for_each = local.environments

  workspace_name      = "${each.key}-databricks-ws"
  resource_group_name = module.resource_group[each.key].name
  location            = module.resource_group[each.key].location

  vnet_id             = module.networking[each.key].vnet_id
  public_subnet_name  = module.networking[each.key].public_subnet_name
  private_subnet_name = module.networking[each.key].private_subnet_name

  public_subnet_nsg_association_id  = module.networking[each.key].public_subnet_nsg_association_id
  private_subnet_nsg_association_id = module.networking[each.key].private_subnet_nsg_association_id
}

module "access_connector" {
  source = "./modules/access_connector"

  for_each = local.environments

  name                = "${each.key}-databricks-access-connector"
  resource_group_name = module.resource_group[each.key].name
  location            = module.resource_group[each.key].location

  storage_account_id = module.storage[each.key].storage_account_id
}