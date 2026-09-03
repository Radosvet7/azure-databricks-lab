resource "random_string" "storage_suffix" {
  for_each = local.environments

  length  = 8
  special = false
  upper   = false
}