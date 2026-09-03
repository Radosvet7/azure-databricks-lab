resource "databricks_storage_credential" "this" {
  name = var.storage_credential_name

  azure_managed_identity {
    access_connector_id = var.access_connector_id
  }

  comment = "Managed by Terraform"
}

resource "databricks_external_location" "this" {
  name = "${var.container_name}-external-location"

  url = "abfss://${var.container_name}@${var.storage_account_name}.dfs.core.windows.net/"

  credential_name = databricks_storage_credential.this.name

  comment = "Managed by Terraform"
}