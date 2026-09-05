resource "databricks_storage_credential" "this" {
  name           = var.storage_credential_name
  isolation_mode = "ISOLATION_MODE_ISOLATED"
  force_update   = true
  force_destroy  = true
  metastore_id   = var.metastore_id
  provider       = databricks.account
  api            = "account"

  azure_managed_identity {
    access_connector_id = var.access_connector_id
  }

  comment = "Managed by Terraform"
}

resource "databricks_external_location" "data" {
  name           = var.external_location_name
  isolation_mode = "ISOLATION_MODE_ISOLATED"
  force_update   = true
  force_destroy  = true
  provider       = databricks.account
  metastore_id   = var.metastore_id
  url            = var.data_container_url

  credential_name = databricks_storage_credential.this.name

  comment = "Managed by Terraform"

  provider_config {
    workspace_id = tostring(var.workspace_id)
  }
}

resource "databricks_external_location" "managed" {
  name           = var.managed_external_location_name
  isolation_mode = "ISOLATION_MODE_ISOLATED"
  force_update   = true
  force_destroy  = true
  provider       = databricks.account
  metastore_id   = var.metastore_id
  url            = var.unity_catalog_container_url

  credential_name = databricks_storage_credential.this.name

  comment = "Managed by Terraform"

  provider_config {
    workspace_id = tostring(var.workspace_id)
  }
}

resource "databricks_catalog" "this" {
  provider       = databricks.account
  name           = var.catalog_name
  metastore_id   = var.metastore_id
  isolation_mode = "ISOLATED"
  force_destroy  = true

  storage_root = var.unity_catalog_container_url

  comment = "Managed by Terraform"

  depends_on = [databricks_external_location.managed]
  provider_config {
    workspace_id = tostring(var.workspace_id)
  }
}

resource "databricks_schema" "this" {
  provider = databricks.account

  for_each = var.schemas

  catalog_name  = databricks_catalog.this.name
  name          = each.value
  metastore_id  = var.metastore_id
  force_destroy = true
  comment       = "Managed by Terraform"

  provider_config {
    workspace_id = tostring(var.workspace_id)
  }
}

resource "databricks_workspace_binding" "catalog" {
  securable_name = databricks_catalog.this.name
  workspace_id   = var.workspace_id
  provider       = databricks.account
  securable_type = "catalog"
  binding_type   = "BINDING_TYPE_READ_WRITE"
  provider_config {
    workspace_id = tostring(var.workspace_id)
  }
}

resource "databricks_workspace_binding" "storage_credential" {
  securable_name = databricks_storage_credential.this.name
  workspace_id   = var.workspace_id
  provider       = databricks.account
  securable_type = "storage_credential"
  provider_config {
    workspace_id = tostring(var.workspace_id)
  }
}

resource "databricks_workspace_binding" "external_locations" {
  for_each = {
    data    = databricks_external_location.data.name
    managed = databricks_external_location.managed.name
  }
  provider       = databricks.account
  securable_name = each.value
  workspace_id   = var.workspace_id

  securable_type = "external_location"
  provider_config {
    workspace_id = tostring(var.workspace_id)
  }
}