variable "resource_group_name" {
  description = "Name of the resource group where resources will be created."
  type        = string

  validation {
    condition     = length(var.resource_group_name) > 0 && length(var.resource_group_name) <= 90
    error_message = "Resource group name must be between 1 and 90 characters."
  }
}

variable "location" {
  description = "Azure region for all resources."
  type        = string

  validation {
    condition     = length(var.location) > 0
    error_message = "Location must not be empty."
  }
}

variable "hub_workspace_name" {
  description = "Name of the Azure AI Hub workspace."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{2,32}$", var.hub_workspace_name))
    error_message = "Hub workspace name must start with a letter, be 3-33 characters, and contain only letters, numbers, and hyphens."
  }
}

variable "hub_display_name" {
  description = "Display name for the AI Hub workspace."
  type        = string
  default     = ""
}

variable "hub_description" {
  description = "Description for the AI Hub workspace."
  type        = string
  default     = "Azure AI Hub Workspace"
}

variable "hub_sku_name" {
  description = "SKU name for the AI Hub workspace (Basic, Standard, or Premium)."
  type        = string
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.hub_sku_name)
    error_message = "SKU name must be one of: Basic, Standard, Premium."
  }
}

variable "storage_account_id" {
  description = "Resource ID of the Storage Account for the hub workspace."
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/[a-f0-9-]+/resourceGroups/.+/providers/Microsoft.Storage/storageAccounts/.+$", var.storage_account_id))
    error_message = "Must be a valid Azure Storage Account resource ID."
  }
}

variable "key_vault_id" {
  description = "Resource ID of the Key Vault for the hub workspace."
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/[a-f0-9-]+/resourceGroups/.+/providers/Microsoft.KeyVault/vaults/.+$", var.key_vault_id))
    error_message = "Must be a valid Azure Key Vault resource ID."
  }
}

variable "application_insights_id" {
  description = "Resource ID of Application Insights for the hub workspace."
  type        = string
  default     = null
}

variable "container_registry_id" {
  description = "Resource ID of the Container Registry for the hub workspace."
  type        = string
  default     = null
}

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled for the hub workspace."
  type        = bool
  default     = true
}

variable "managed_identity_type" {
  description = "Type of managed identity for the hub workspace."
  type        = string
  default     = "SystemAssigned"

  validation {
    condition     = contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.managed_identity_type)
    error_message = "Identity type must be SystemAssigned, UserAssigned, or 'SystemAssigned, UserAssigned'."
  }
}

variable "user_assigned_identity_ids" {
  description = "List of user-assigned managed identity IDs for the hub workspace."
  type        = list(string)
  default     = []
}

variable "primary_user_assigned_identity_id" {
  description = "Resource ID of the primary user-assigned identity."
  type        = string
  default     = null
}

variable "projects" {
  description = "Map of AI Studio projects to create within the hub workspace."
  type = map(object({
    display_name = optional(string, "")
    description  = optional(string, "")
    sku_name     = optional(string, "Basic")
    tags         = optional(map(string), {})
  }))
  default = {}
}

variable "compute_instances" {
  description = "Map of compute instances to create in the hub workspace."
  type = map(object({
    vm_size                       = string
    description                   = optional(string, "")
    authorization_type            = optional(string, "personal")
    local_auth_enabled            = optional(bool, true)
    subnet_resource_id            = optional(string, null)
    assign_to_user_object_id      = optional(string, null)
    assign_to_user_tenant_id      = optional(string, null)
    ssh_public_access_enabled     = optional(bool, false)
    idle_time_before_shutdown_min = optional(number, null)
    tags                          = optional(map(string), {})
  }))
  default = {}
}

variable "model_deployments" {
  description = "Map of model deployments via Cognitive Services account."
  type = map(object({
    cognitive_account_id = string
    model_name           = string
    model_version        = string
    model_format         = optional(string, "OpenAI")
    scale_type           = optional(string, "Standard")
    scale_capacity       = optional(number, 1)
    rai_policy_name      = optional(string, null)
  }))
  default = {}
}

variable "connections" {
  description = "Map of AI Studio connections to external services."
  type = map(object({
    target          = string
    category        = string
    auth_type       = optional(string, "AAD")
    credentials_key = optional(string, null)
    metadata        = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.connections : contains([
        "AzureOpenAI", "CognitiveSearch", "CognitiveService",
        "AzureBlob", "AzureSqlDb", "CustomKeys", "ApiKey"
      ], v.category)
    ])
    error_message = "Connection category must be one of: AzureOpenAI, CognitiveSearch, CognitiveService, AzureBlob, AzureSqlDb, CustomKeys, ApiKey."
  }
}

variable "private_endpoints" {
  description = "Map of private endpoints for the hub workspace."
  type = map(object({
    subnet_id                       = string
    private_dns_zone_ids            = optional(list(string), [])
    is_manual_connection            = optional(bool, false)
    subresource_names               = optional(list(string), ["amlworkspace"])
    private_service_connection_name = optional(string, null)
  }))
  default = {}
}

variable "encryption" {
  description = "Customer-managed key encryption configuration."
  type = object({
    key_vault_key_id          = string
    user_assigned_identity_id = optional(string, null)
  })
  default = null
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}
