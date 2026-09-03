resource "databricks_storage_credential" "this" {
  name           = var.storage_credential_name
  isolation_mode = "ISOLATION_MODE_ISOLATED"
  force_update   = true

  azure_managed_identity {
    access_connector_id = var.access_connector_id
  }

  comment = "Managed by Terraform"
}

resource "databricks_external_location" "data" {
  name           = var.external_location_name
  isolation_mode = "ISOLATION_MODE_ISOLATED"

  url = "abfss://${var.data_container_name}@${var.storage_account_name}.dfs.core.windows.net/"

  credential_name = databricks_storage_credential.this.name

  comment = "Managed by Terraform"
}

resource "databricks_external_location" "managed" {
  name           = var.managed_external_location_name
  isolation_mode = "ISOLATION_MODE_ISOLATED"

  url = "abfss://${var.unity_catalog_container_name}@${var.storage_account_name}.dfs.core.windows.net/"

  credential_name = databricks_storage_credential.this.name

  comment = "Managed by Terraform"
}

resource "databricks_catalog" "this" {
  name           = var.catalog_name
  isolation_mode = "ISOLATED"

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

resource "databricks_workspace_binding" "catalog" {
  securable_name = databricks_catalog.this.name
  workspace_id   = var.workspace_id

  securable_type = "catalog"
  binding_type   = "BINDING_TYPE_READ_WRITE"
}

resource "databricks_workspace_binding" "storage_credential" {
  securable_name = databricks_storage_credential.this.name
  workspace_id   = var.workspace_id

  securable_type = "storage_credential"
}

resource "databricks_workspace_binding" "external_locations" {
  for_each = {
    data    = databricks_external_location.data.name
    managed = databricks_external_location.managed.name
  }

  securable_name = each.value
  workspace_id   = var.workspace_id

  securable_type = "external_location"
}