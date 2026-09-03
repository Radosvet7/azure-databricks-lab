output "storage_credential_id" {
  value = databricks_storage_credential.this.id
}

output "storage_credential_name" {
  value = databricks_storage_credential.this.name
}

output "data_external_location_id" {
  value = databricks_external_location.data.id
}

output "data_external_location_url" {
  value = databricks_external_location.data.url
}
