variable "databricks_account_id" {
  type = string
}

variable "azure_tenant_id" {
  type = string
}

data "databricks_metastores" "this" {
  provider = databricks.account
}