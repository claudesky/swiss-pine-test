variable "location" {}

variable "resource_group_name" {}

variable "main_virtual_network_name" {}

variable "main_virtual_network_address_space" {}

variable "cluster_subnet_name" {}

variable "cluster_subnet_address_prefixes" {
  type = set(string)
}

variable "cluster_subnet_security_group_name" {}
