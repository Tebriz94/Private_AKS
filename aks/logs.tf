##All the AKS logs can be sent to a log analytics workspace with the OMS agent addon.


resource "azurerm_log_analytics_workspace" "log" {
  name                = "log-pvaks-001"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}