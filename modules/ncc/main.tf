resource "databricks_mws_network_connectivity_config" "this" {
  provider = databricks.account

  name   = var.name
  region = var.region
}

resource "databricks_mws_ncc_binding" "this" {
  provider = databricks.account

  network_connectivity_config_id = databricks_mws_network_connectivity_config.this.network_connectivity_config_id
  workspace_id                   = var.workspace_id
}

resource "databricks_mws_ncc_private_endpoint_rule" "storage" {
  provider = databricks.account

  network_connectivity_config_id = databricks_mws_network_connectivity_config.this.network_connectivity_config_id

  resource_id = var.storage_account_id
  group_id    = "dfs"
}