
resource "random_string" "suffix" {
                length  = 6
                upper   = false
                special = false
                numeric = true
}

resource "azurerm_container_registry" "acr" {
  name                          = "acrpvaks${random_string.suffix.result}"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  sku                           = "Premium"
  admin_enabled                 = false
  public_network_access_enabled = false
}

resource "azurerm_private_dns_zone" "acr" {
  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "acr1" {
  name                  = "pdznl-acr-001"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.acr.name
  virtual_network_id    = azurerm_virtual_network.vnet_hub.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "acr2" {
  name                  = "pdznl-acr-002"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.acr.name
  virtual_network_id    = azurerm_virtual_network.vnet_aks.id
}

resource "azurerm_private_endpoint" "acr" {
  name                = "pe-acr-001"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.global.id

  private_service_connection {
    name                           = "psc-acr-001"
    private_connection_resource_id = azurerm_container_registry.acr.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "pdzg-acr-001"
    private_dns_zone_ids = [azurerm_private_dns_zone.acr.id]
  }
}