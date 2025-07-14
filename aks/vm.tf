
# Create a network interface for the VM
resource "azurerm_network_interface" "nic" {
  name                = "nic-vm-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.global.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create a Windows Virtual Machine using the above NIC
resource "azurerm_windows_virtual_machine" "vm1" {
  name                = "vm-1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_D2s_v3"
  admin_username      = var.vm_username
  admin_password      = var.vm_password
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Reference the Windows 10 Pro image to deploy
  source_image_reference {
    publisher = "microsoftwindowsdesktop"
    offer     = "Windows-10"
    sku       = "win10-22h2-pro"
    version   = "latest"
  }
}

# Variable for VM admin username
variable "vm_username" {
  type        = string
  description = "Username for vm-1"
}

# Variable for VM admin password (sensitive info)
variable "vm_password" {
  type        = string
  sensitive   = true
  description = "Password for vm-1"
}