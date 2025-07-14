
# Create the Hub Virtual Network (central VNet for shared services)
resource "azurerm_virtual_network" "vnet_hub" {
  name                = "vnet-hub"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

# Create the AKS Virtual Network (dedicated VNet for AKS workloads)
resource "azurerm_virtual_network" "vnet_aks" {
  name                = "vnet-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.1.0.0/16"]
}

# Peer the Hub VNet to the AKS VNet
resource "azurerm_virtual_network_peering" "to_vnet_aks" {
  name                         = "peer-to-vnet-aks"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.vnet_hub.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet_aks.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
}

# Peer the AKS VNet back to the Hub VNet (bi-directional peering)
resource "azurerm_virtual_network_peering" "to_vnet_hub" {
  name                         = "peer-to-vnet-hub"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.vnet_aks.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet_hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

# Subnet for Azure Bastion in the Hub VNet (mandatory subnet name for Bastion)
resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_hub.name
  address_prefixes     = ["10.0.0.0/27"]
}

# General-purpose subnet in the Hub VNet with Private Link policies enabled
resource "azurerm_subnet" "global" {
  name                                      = "snet-global"
  resource_group_name                       = azurerm_resource_group.rg.name
  virtual_network_name                      = azurerm_virtual_network.vnet_hub.name
  address_prefixes                          = ["10.0.1.0/24"]
  private_link_service_network_policies_enabled = true
}

# Application Gateway subnet in the AKS VNet
resource "azurerm_subnet" "agw" {
  name                 = "snet-agw"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_aks.name
  address_prefixes     = ["10.1.0.0/24"]
}

# AKS cluster node subnet in the AKS VNet with Private Link policies enabled
resource "azurerm_subnet" "aks" {
  name                                      = "snet-aks"
  resource_group_name                       = azurerm_resource_group.rg.name
  virtual_network_name                      = azurerm_virtual_network.vnet_aks.name
  address_prefixes                          = ["10.1.1.0/24"]
  private_link_service_network_policies_enabled = true
}
 

# Utility subnet in the AKS VNet for supporting resources (e.g., Private Endpoints, Bastion, etc.)
resource "azurerm_subnet" "utils" {
  name                                      = "snet-utils"
  resource_group_name                       = azurerm_resource_group.rg.name
  virtual_network_name                      = azurerm_virtual_network.vnet_aks.name
  address_prefixes                          = ["10.1.2.0/24"]
  private_link_service_network_policies_enabled = true
}