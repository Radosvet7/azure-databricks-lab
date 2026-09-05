variable "storage_credential_name" {
  type = string
}

variable "access_connector_id" {
  type = string
}

variable "external_location_name" {
  type = string
}

variable "managed_external_location_name" {
  type = string
}

variable "catalog_name" {
  type = string
}

variable "schemas" {
  type = set(string)
}

variable "workspace_id" {
  type = number
}

variable "data_container_url" {
  type = string
}

variable "unity_catalog_container_url" {
  type = string
}

variable "metastore_id" {
  type = string
}