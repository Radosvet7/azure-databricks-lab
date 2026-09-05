variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "vnet_address_space" {
  type = list(string)
}

variable "public_subnet_name" {
  type = string
}

variable "public_subnet_prefixes" {
  type = list(string)
}

variable "private_subnet_name" {
  type = string
}

variable "private_subnet_prefixes" {
  type = list(string)
}

variable "private_endpoint_subnet_name" {
  type = string
}

variable "private_endpoint_subnet_prefixes" {
  type = list(string)
}
