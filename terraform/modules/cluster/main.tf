resource "azurerm_network_security_group" "cluster" {
  name                = var.cluster_subnet_security_group_name
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow_HTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "443"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet" "cluster" {
  name                 = var.cluster_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.main_virtual_network_name
  address_prefixes     = var.cluster_subnet_address_prefixes

  service_endpoints = ["Microsoft.Sql", "Microsoft.Storage", "Microsoft.KeyVault"]
}
