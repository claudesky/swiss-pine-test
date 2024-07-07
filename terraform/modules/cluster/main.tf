locals {
  vnet_name = "${var.resource_group_name}-${var.name}"
}

resource "azurerm_resource_group" "resource_group" {
  name = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name = local.vnet_name
  location = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  address_space = [ "10.0.0.0/12" ]
}

resource "azurerm_subnet" "vm_subnet" {
  name = "vm_subnet"
  resource_group_name = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "pod_subnet" {
  name = "pod_subnet"
  resource_group_name = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["10.2.0.0/16"]

  service_endpoints = ["Microsoft.Sql"]
}

resource "azurerm_kubernetes_cluster" "cluster" {
  depends_on = [ azurerm_resource_group.resource_group ]
  name                = var.name
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name
  node_resource_group = "${azurerm_resource_group.resource_group.name}-node-resource-group"
  sku_tier = "Free"
  dns_prefix          = var.name
  kubernetes_version  = "1.29.4"

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
    service_cidr      = "10.0.0.0/16"
    dns_service_ip = "10.0.0.10"
  }

  default_node_pool {
    name            = "default"
    node_count      = 1
    vm_size         = "Standard_D2_v2"
    os_disk_size_gb = 30
    vnet_subnet_id = azurerm_subnet.pod_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  oidc_issuer_enabled = true
  workload_identity_enabled = true

  lifecycle {
    ignore_changes = [ default_node_pool[0].upgrade_settings ]
  }
}

resource "azurerm_role_assignment" "attach_acr" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.cluster.kubelet_identity[0].object_id
}
