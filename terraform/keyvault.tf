resource "azurerm_key_vault" "vault" {
  # name                        = "hello-keyvault"
  name                        = var.keyvault_name
  location                    = azurerm_resource_group.resource_group.location
  resource_group_name         = azurerm_resource_group.resource_group.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get",
      "Set",
      "Delete",
      "List"
    ]

    storage_permissions = [
      "Get",
    ]
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_kubernetes_cluster.k8s.key_vault_secrets_provider[0].secret_identity[0].object_id

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Recover",
      "Backup",
      "Restore",    
    ]

  }
}

# Create an azure secret with a random initial value, ignore changes afterwards

resource "random_pet" "secret" {
  length    = 10
}

resource "azurerm_key_vault_secret" "secret" {
  name         = "demo-secret"
  value        = random_pet.secret.id
  key_vault_id = azurerm_key_vault.vault.id

  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}
