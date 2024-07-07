provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = var.kube_context
  }
}

resource "helm_release" "app" {
  depends_on = [
    azurerm_postgresql_flexible_server.db_server,
    azurerm_postgresql_flexible_server_firewall_rule.db_firewall,
    azurerm_postgresql_flexible_server_configuration.ssl_off,
    azurerm_postgresql_flexible_server_database.db
  ]
  name       = var.name
  repository = "${path.module}"
  chart      = "./charts/app/app-1.0.0.tgz"
  namespace  = var.name
  create_namespace = true

  set {
    name = "image.repository"
    value = "${var.acr_name}.azurecr.io/${var.name}"
  }
  set {
    name = "image.tag"
    value = var.app_version
  }
  set {
    name = "env.DB_USER"
    value = "postgres"
  }
  set {
    name = "env.DB_HOST"
    value = azurerm_postgresql_flexible_server.db_server.fqdn
  }
  set_sensitive {
    name = "env.DB_PASS"
    value = "notASecurePassword1#"
  }
}

resource "azurerm_subnet" "db_subnet" {
  name                 = "${var.name}-db-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.cluster_vnet_name
  address_prefixes     = ["10.3.0.0/24"]
  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_private_dns_zone" "db_private_dns_zone" {
  name                = "${var.name}.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "db_vnet_link" {
  name                  = "private-vnet-link"
  private_dns_zone_name = azurerm_private_dns_zone.db_private_dns_zone.name
  virtual_network_id    = var.cluster_vnet_id
  resource_group_name   = var.resource_group_name
  depends_on            = [ azurerm_subnet.db_subnet ]
}

resource "azurerm_postgresql_flexible_server" "db_server" {
  name                          = "${var.name}-db"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = "16"
  delegated_subnet_id           = azurerm_subnet.db_subnet.id
  private_dns_zone_id           = azurerm_private_dns_zone.db_private_dns_zone.id
  public_network_access_enabled = false
  administrator_login           = "postgres"
  administrator_password        = "notASecurePassword1#"
  zone                          = "1"

  storage_mb   = 32768
  storage_tier = "P4"
  auto_grow_enabled = false

  sku_name   = "B_Standard_B1ms"
  depends_on = [azurerm_private_dns_zone_virtual_network_link.db_vnet_link]
}

resource "azurerm_postgresql_flexible_server_database" "db" {
  name      = "${var.db_name}"
  server_id = azurerm_postgresql_flexible_server.db_server.id
  collation = "en_US.utf8"
  charset   = "utf8"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "db_firewall" {
  name                = "allow_service_access"
  server_id         = azurerm_postgresql_flexible_server.db_server.id
  start_ip_address    = "10.0.0.0"
  end_ip_address      = "10.15.255.255"
}

resource "azurerm_postgresql_flexible_server_configuration" "ssl_off" {
  name = "require_secure_transport"
  value = "off"
  server_id = azurerm_postgresql_flexible_server.db_server.id
}
