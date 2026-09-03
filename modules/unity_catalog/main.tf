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

resource "databricks_external_location" "managed" {
  name = var.managed_external_location_name

  url = "abfss://${var.unity_catalog_container_name}@${var.storage_account_name}.dfs.core.windows.net/"

  credential_name = databricks_storage_credential.this.name

  comment = "Managed by Terraform"
}

resource "databricks_catalog" "this" {
  name = var.catalog_name

  storage_root = "abfss://${var.unity_catalog_container_name}@${var.storage_account_name}.dfs.core.windows.net/"

  comment = "Managed by Terraform"

  depends_on = [databricks_external_location.managed]
}

resource "databricks_schema" "this" {
  for_each = var.schemas

  catalog_name = databricks_catalog.this.name
  name         = each.value

  comment = "Managed by Terraform"
}