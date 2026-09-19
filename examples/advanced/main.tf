provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-ai-studio-advanced"
  location = "East US"
}

resource "azurerm_storage_account" "example" {
  name                     = "staistudioadv001"
  location                 = azurerm_resource_group.example.location
  resource_group_name      = azurerm_resource_group.example.name
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_key_vault" "example" {
  name                = "kv-ai-studio-adv-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}

resource "azurerm_application_insights" "example" {
  name                = "appi-ai-studio-adv"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  application_type    = "web"
}

resource "azurerm_container_registry" "example" {
  name                = "craistudioadv001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "Standard"
}

resource "azurerm_cognitive_account" "openai" {
  name                = "oai-studio-adv-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  kind                = "OpenAI"
  sku_name            = "S0"
}

data "azurerm_client_config" "current" {}

module "ai_studio" {
  source = "../../"

  resource_group_name     = azurerm_resource_group.example.name
  location                = azurerm_resource_group.example.location
  hub_workspace_name      = "hub-advanced-001"
  hub_display_name        = "AI Hub Advanced"
  hub_description         = "Advanced AI Hub with projects and model deployments"
  hub_sku_name            = "Standard"
  storage_account_id      = azurerm_storage_account.example.id
  key_vault_id            = azurerm_key_vault.example.id
  application_insights_id = azurerm_application_insights.example.id
  container_registry_id   = azurerm_container_registry.example.id

  projects = {
    "project-nlp" = {
      display_name = "NLP Research Project"
      description  = "Natural Language Processing research"
    }
    "project-vision" = {
      display_name = "Computer Vision Project"
      description  = "Computer Vision models and experiments"
    }
  }

  compute_instances = {
    "ci-dev-01" = {
      vm_size            = "Standard_DS3_v2"
      description        = "Development compute instance"
      authorization_type = "personal"
    }
  }

  model_deployments = {
    "gpt-4o-deployment" = {
      cognitive_account_id = azurerm_cognitive_account.openai.id
      model_name           = "gpt-4o"
      model_version        = "2024-05-13"
      model_format         = "OpenAI"
      scale_type           = "Standard"
      scale_capacity       = 10
    }
  }

  tags = {
    Environment = "staging"
    Project     = "ai-studio-advanced"
  }
}

output "hub_workspace_id" {
  value = module.ai_studio.hub_workspace_id
}

output "project_ids" {
  value = module.ai_studio.project_ids
}
