data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "rg-ai-studio-test"
  location = "eastus2"
}

resource "azurerm_storage_account" "test" {
  name                     = "staistudiotest001"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_key_vault" "test" {
  name                       = "kv-ai-studio-test001"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  purge_protection_enabled   = false
  soft_delete_retention_days = 7
}

resource "azurerm_application_insights" "test" {
  name                = "appi-ai-studio-test"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

module "test" {
  source = "../"

  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  hub_workspace_name  = "hub-ai-studio-test"
  hub_display_name    = "AI Studio Test Hub"
  hub_description     = "Test AI Hub workspace for validation"
  hub_sku_name        = "Basic"

  storage_account_id      = azurerm_storage_account.test.id
  key_vault_id            = azurerm_key_vault.test.id
  application_insights_id = azurerm_application_insights.test.id

  projects = {
    "proj-test" = {
      display_name = "Test Project"
      description  = "Test AI Studio project"
    }
  }

  tags = {
    Environment = "test"
    Terraform   = "true"
  }
}
