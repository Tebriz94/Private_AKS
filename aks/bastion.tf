
# Create a static public IP address for the Bastion Host
resource "azurerm_public_ip" "bas" {
  name                = "pip-bas-cac-001"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create an Azure Bastion Host for secure access to virtual machines
resource "azurerm_bastion_host" "bas" {
  name                = "bas-pvaks-001"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bas.id
  }
}