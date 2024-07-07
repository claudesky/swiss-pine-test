output "kubernetes_oidc_issuer_url" {
  value = azurerm_kubernetes_cluster.cluster.oidc_issuer_url
}

output "context" {
  value = var.context
}

output "cluster_subnet_id" {
  value = azurerm_subnet.pod_subnet.id
}

output "cluster_vnet_name" {
  value = azurerm_virtual_network.vnet.name
}

output "cluster_vnet_id" {
  value = azurerm_virtual_network.vnet.id
}
