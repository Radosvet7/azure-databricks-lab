resource "databricks_storage_credential" "this" {
  name = var.storage_credential_name

  azure_managed_identity {
    access_connector_id = var.access_connector_id
  }

  comment = "Managed by Terraform"
}

resource "databricks_external_location" "data" {
  name = var.external_location_name

  url = "abfss://${var.data_container_name}@${var.storage_account_name}.dfs.core.windows.net/"

  credential_name = databricks_storage_credential.this.name

  comment = "Managed by Terraform"
}