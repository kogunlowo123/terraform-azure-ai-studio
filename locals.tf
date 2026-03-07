locals {
  hub_display_name = var.hub_display_name != "" ? var.hub_display_name : var.hub_workspace_name

  common_tags = merge(var.tags, {
    ManagedBy = "Terraform"
    Module    = "terraform-azure-ai-studio"
  })

  identity_config = {
    type         = var.managed_identity_type
    identity_ids = var.managed_identity_type != "SystemAssigned" ? var.user_assigned_identity_ids : null
  }

  projects_with_defaults = {
    for k, v in var.projects : k => merge(v, {
      display_name = v.display_name != "" ? v.display_name : k
    })
  }

  compute_instances_flat = {
    for k, v in var.compute_instances : k => merge(v, {
      name = k
    })
  }

  private_endpoints_with_defaults = {
    for k, v in var.private_endpoints : k => merge(v, {
      private_service_connection_name = v.private_service_connection_name != null ? v.private_service_connection_name : "${var.hub_workspace_name}-${k}-psc"
    })
  }
}
