provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-ai-studio-complete"
  location = "East US"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-ai-studio"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "private_endpoints" {
  name                 = "snet-private-endpoints"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "compute" {
  name                 = "snet-compute"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_private_dns_zone" "ml" {
  name                = "privatelink.api.azureml.ms"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "ml" {
  name                = "ml-vnet-link"
  private_dns_zone_id = azurerm_private_dns_zone.ml.id
  virtual_network_id  = azurerm_virtual_network.example.id
}

resource "azurerm_storage_account" "example" {
  name                     = "staistudiocomplete001"
  location                 = azurerm_resource_group.example.location
  resource_group_name      = azurerm_resource_group.example.name
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_key_vault" "example" {
  name                       = "kv-ai-studio-comp-001"
  location                   = azurerm_resource_group.example.location
  resource_group_name        = azurerm_resource_group.example.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 90
  purge_protection_enabled   = true
  rbac_authorization_enabled = true
}

resource "azurerm_application_insights" "example" {
  name                = "appi-ai-studio-complete"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  application_type    = "web"
}

resource "azurerm_container_registry" "example" {
  name                = "craistudiocomplete001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "Premium"
}

resource "azurerm_user_assigned_identity" "example" {
  name                = "id-ai-studio-complete"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_cognitive_account" "openai" {
  name                = "oai-studio-complete-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  kind                = "OpenAI"
  sku_name            = "S0"
}

resource "azurerm_cognitive_account" "search" {
  name                = "cog-search-complete-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  kind                = "CognitiveServices"
  sku_name            = "S0"
}

data "azurerm_client_config" "current" {}

module "ai_studio" {
  source = "../../"

  resource_group_name     = azurerm_resource_group.example.name
  location                = azurerm_resource_group.example.location
  hub_workspace_name      = "hub-complete-001"
  hub_display_name        = "AI Hub Complete"
  hub_description         = "Full-featured AI Hub with all integrations"
  hub_sku_name            = "Standard"
  storage_account_id      = azurerm_storage_account.example.id
  key_vault_id            = azurerm_key_vault.example.id
  application_insights_id = azurerm_application_insights.example.id
  container_registry_id   = azurerm_container_registry.example.id

  public_network_access_enabled = false

  managed_identity_type             = "SystemAssigned, UserAssigned"
  user_assigned_identity_ids        = [azurerm_user_assigned_identity.example.id]
  primary_user_assigned_identity_id = azurerm_user_assigned_identity.example.id

  projects = {
    "project-nlp" = {
      display_name = "NLP Research"
      description  = "Natural Language Processing research project"
      tags         = { Team = "NLP" }
    }
    "project-vision" = {
      display_name = "Computer Vision"
      description  = "Computer Vision experiments"
      tags         = { Team = "Vision" }
    }
    "project-agents" = {
      display_name = "AI Agents"
      description  = "Autonomous AI agent development"
      tags         = { Team = "Agents" }
    }
  }

  compute_instances = {
    "ci-dev-01" = {
      vm_size            = "Standard_DS3_v2"
      description        = "Development compute"
      authorization_type = "personal"
      subnet_resource_id = azurerm_subnet.compute.id
    }
    "ci-train-01" = {
      vm_size            = "Standard_NC6s_v3"
      description        = "Training compute with GPU"
      authorization_type = "personal"
      subnet_resource_id = azurerm_subnet.compute.id
    }
  }

  model_deployments = {
    "gpt-4o" = {
      cognitive_account_id = azurerm_cognitive_account.openai.id
      model_name           = "gpt-4o"
      model_version        = "2024-05-13"
      model_format         = "OpenAI"
      scale_type           = "Standard"
      scale_capacity       = 20
    }
    "text-embedding-ada-002" = {
      cognitive_account_id = azurerm_cognitive_account.openai.id
      model_name           = "text-embedding-ada-002"
      model_version        = "2"
      model_format         = "OpenAI"
      scale_type           = "Standard"
      scale_capacity       = 30
    }
  }

  private_endpoints = {
    "hub" = {
      subnet_id            = azurerm_subnet.private_endpoints.id
      private_dns_zone_ids = [azurerm_private_dns_zone.ml.id]
      subresource_names    = ["amlworkspace"]
    }
  }

  tags = {
    Environment = "production"
    Project     = "ai-studio-complete"
    CostCenter  = "AI-001"
  }
}

output "hub_workspace_id" {
  value = module.ai_studio.hub_workspace_id
}

output "project_ids" {
  value = module.ai_studio.project_ids
}

output "compute_instance_ids" {
  value = module.ai_studio.compute_instance_ids
}

output "model_deployment_ids" {
  value = module.ai_studio.model_deployment_ids
}

output "private_endpoint_ids" {
  value = module.ai_studio.private_endpoint_ids
}
