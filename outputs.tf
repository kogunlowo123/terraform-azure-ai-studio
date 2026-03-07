output "hub_workspace_id" {
  description = "Resource ID of the AI Hub workspace."
  value       = azurerm_machine_learning_workspace.hub.id
}

output "hub_workspace_name" {
  description = "Name of the AI Hub workspace."
  value       = azurerm_machine_learning_workspace.hub.name
}

output "hub_workspace_principal_id" {
  description = "Principal ID of the hub workspace managed identity."
  value       = try(azurerm_machine_learning_workspace.hub.identity[0].principal_id, null)
}

output "hub_workspace_tenant_id" {
  description = "Tenant ID of the hub workspace managed identity."
  value       = try(azurerm_machine_learning_workspace.hub.identity[0].tenant_id, null)
}

output "hub_workspace_discovery_url" {
  description = "Discovery URL of the AI Hub workspace."
  value       = azurerm_machine_learning_workspace.hub.discovery_url
}

output "project_ids" {
  description = "Map of project names to their resource IDs."
  value       = { for k, v in azurerm_machine_learning_workspace.projects : k => v.id }
}

output "project_principal_ids" {
  description = "Map of project names to their managed identity principal IDs."
  value       = { for k, v in azurerm_machine_learning_workspace.projects : k => try(v.identity[0].principal_id, null) }
}

output "compute_instance_ids" {
  description = "Map of compute instance names to their resource IDs."
  value       = { for k, v in azurerm_machine_learning_compute_instance.this : k => v.id }
}

output "model_deployment_ids" {
  description = "Map of model deployment names to their resource IDs."
  value       = { for k, v in azurerm_cognitive_deployment.this : k => v.id }
}

output "private_endpoint_ids" {
  description = "Map of private endpoint names to their resource IDs."
  value       = { for k, v in azurerm_private_endpoint.this : k => v.id }
}

output "private_endpoint_ip_addresses" {
  description = "Map of private endpoint names to their private IP addresses."
  value       = { for k, v in azurerm_private_endpoint.this : k => v.private_service_connection[0].private_ip_address }
}
