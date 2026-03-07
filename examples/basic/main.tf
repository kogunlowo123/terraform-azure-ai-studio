provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-ai-studio-basic"
  location = "East US"
}

resource "azurerm_storage_account" "example" {
  name                     = "staistudiobasic001"
  location                 = azurerm_resource_group.example.location
  resource_group_name      = azurerm_resource_group.example.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_key_vault" "example" {
  name                = "kv-ai-studio-basic-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}

data "azurerm_client_config" "current" {}

module "ai_studio" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  hub_workspace_name  = "hub-basic-001"
  storage_account_id  = azurerm_storage_account.example.id
  key_vault_id        = azurerm_key_vault.example.id

  tags = {
    Environment = "development"
    Project     = "ai-studio-basic"
  }
}

output "hub_workspace_id" {
  value = module.ai_studio.hub_workspace_id
}
