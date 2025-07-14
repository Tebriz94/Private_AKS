## Applications deployed to AKS can access the key vault with the pod identity in order to retrieve secrets.


# Get information about the currently authenticated Azure client (used for tenant ID)
data "azurerm_client_config" "current" {}


# Create an Azure Key Vault
resource "azurerm_key_vault" "kv" {
  name                = "kv-pvaks-001"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

# Assign access policy to allow a user-assigned identity to access secrets
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.pod.principal_id

    secret_permissions = [
      "Get", "List",
    ]
  }
}


# Create a Private DNS Zone for Azure Key Vault
resource "azurerm_private_dns_zone" "kv" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.rg.name
}

# Create a Private DNS Zone for Azure Key Vault
resource "azurerm_private_dns_zone_virtual_network_link" "kv1" {
  name                  = "pdznl-vault-001"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.kv.name
  virtual_network_id    = azurerm_virtual_network.vnet_aks.id
}

# Link the Private DNS Zone to the Hub virtual network (e.g., for shared services or peering)
resource "azurerm_private_dns_zone_virtual_network_link" "kv2" {
  name                  = "pdznl-vault-002"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.kv.name
  virtual_network_id    = azurerm_virtual_network.vnet_hub.id
}

# Create a Private Endpoint for the Key Vault to enable private connectivity
resource "azurerm_private_endpoint" "kv" {
  name                = "pe-vault-001"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.utils.id

  # Configure the private service connection to the Key Vault
  private_service_connection {
    name                           = "psc-vault-001"
    private_connection_resource_id = azurerm_key_vault.kv.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  # Link the Private Endpoint with the appropriate DNS zone
  private_dns_zone_group {
    name                 = "pdzg-vault-001"
    private_dns_zone_ids = [azurerm_private_dns_zone.kv.id]
  }
}