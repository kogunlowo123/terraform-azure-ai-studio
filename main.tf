data "azurerm_client_config" "current" {}

# AI Foundry (AI Studio) hub. azurerm_machine_learning_workspace no longer models
# hubs/projects; the dedicated azurerm_ai_foundry* resources do.
resource "azurerm_ai_foundry" "hub" {
  name                           = var.hub_workspace_name
  location                       = var.location
  resource_group_name            = var.resource_group_name
  application_insights_id        = var.application_insights_id
  key_vault_id                   = var.key_vault_id
  storage_account_id             = var.storage_account_id
  container_registry_id          = var.container_registry_id
  friendly_name                  = var.hub_display_name != "" ? var.hub_display_name : var.hub_workspace_name
  description                    = var.hub_description
  public_network_access          = var.public_network_access_enabled ? "Enabled" : "Disabled"
  primary_user_assigned_identity = var.primary_user_assigned_identity_id

  identity {
    type         = var.managed_identity_type
    identity_ids = var.managed_identity_type != "SystemAssigned" ? var.user_assigned_identity_ids : null
  }

  dynamic "encryption" {
    for_each = var.encryption != null ? [var.encryption] : []
    content {
      key_id                    = encryption.value.key_vault_key_id
      key_vault_id              = coalesce(encryption.value.key_vault_id, var.key_vault_id)
      user_assigned_identity_id = encryption.value.user_assigned_identity_id
    }
  }

  tags = var.tags
}

resource "azurerm_ai_foundry_project" "projects" {
  for_each = {
    for k, v in var.projects : k => merge(v, {
      display_name = v.display_name != "" ? v.display_name : k
    })
  }

  name               = each.key
  location           = var.location
  ai_services_hub_id = azurerm_ai_foundry.hub.id
  friendly_name      = each.value.display_name
  description        = each.value.description

  identity {
    type = "SystemAssigned"
  }

  tags = merge(var.tags, each.value.tags)
}

resource "azurerm_machine_learning_compute_instance" "this" {
  for_each = var.compute_instances

  name                          = each.key
  machine_learning_workspace_id = azurerm_ai_foundry.hub.id
  virtual_machine_size          = each.value.vm_size
  description                   = each.value.description
  authorization_type            = each.value.authorization_type
  local_auth_enabled            = each.value.local_auth_enabled
  subnet_resource_id            = each.value.subnet_resource_id

  dynamic "assign_to_user" {
    for_each = each.value.assign_to_user_object_id != null ? [1] : []
    content {
      object_id = each.value.assign_to_user_object_id
      tenant_id = coalesce(each.value.assign_to_user_tenant_id, data.azurerm_client_config.current.tenant_id)
    }
  }

  tags = merge(var.tags, each.value.tags)
}

resource "azurerm_cognitive_deployment" "this" {
  for_each = var.model_deployments

  name                 = each.key
  cognitive_account_id = each.value.cognitive_account_id

  model {
    format  = each.value.model_format
    name    = each.value.model_name
    version = each.value.model_version
  }

  sku {
    name     = each.value.scale_type
    capacity = each.value.scale_capacity
  }

  rai_policy_name = each.value.rai_policy_name
}

resource "azurerm_machine_learning_workspace_network_outbound_rule_fqdn" "connections" {
  for_each = {
    for k, v in var.connections : k => v
    if v.category == "CustomKeys"
  }

  name             = each.key
  workspace_id     = azurerm_ai_foundry.hub.id
  destination_fqdn = each.value.target
}

resource "azurerm_private_endpoint" "this" {
  for_each = {
    for k, v in var.private_endpoints : k => merge(v, {
      private_service_connection_name = v.private_service_connection_name != null ? v.private_service_connection_name : "${var.hub_workspace_name}-${k}-psc"
    })
  }

  name                = "${var.hub_workspace_name}-${each.key}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = each.value.subnet_id

  private_service_connection {
    name                           = each.value.private_service_connection_name
    private_connection_resource_id = azurerm_ai_foundry.hub.id
    is_manual_connection           = each.value.is_manual_connection
    subresource_names              = each.value.subresource_names
  }

  dynamic "private_dns_zone_group" {
    for_each = length(each.value.private_dns_zone_ids) > 0 ? [1] : []
    content {
      name                 = "default"
      private_dns_zone_ids = each.value.private_dns_zone_ids
    }
  }

  tags = var.tags
}
