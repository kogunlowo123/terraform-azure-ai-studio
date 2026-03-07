data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

data "azurerm_client_config" "current" {}

data "azurerm_storage_account" "this" {
  name                = split("/", var.storage_account_id)[8]
  resource_group_name = split("/", var.storage_account_id)[4]
}

data "azurerm_key_vault" "this" {
  name                = split("/", var.key_vault_id)[8]
  resource_group_name = split("/", var.key_vault_id)[4]
}
