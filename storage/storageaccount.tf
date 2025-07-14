terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.35.0"
    }
  }

}

provider "azurerm" {
  # Configuration options

  features {
    
  }

  subscription_id = "" ## your azure subscription id but this is demo you should use Azure Vault for secure.
  
}


# Create an Azure Resource Group named 'tfstate-rg' in the 'East US' region.
# This is typically used to hold related resources, such as storage accounts for Terraform state.
resource "azurerm_resource_group" "rg" {
                name     = "tfstate-rg"
                location = "East US"
}

# Generate a random 6-character string consisting of lowercase letters and numbers.
# This is often used as a suffix to ensure uniqueness in resource names.
resource "random_string" "suffix" {
                length  = 6
                upper   = false
                special = false
                numeric = true
}


# Create an Azure Storage Account for storing the Terraform state file.
# The name includes a random suffix to ensure global uniqueness (required by Azure).
resource "azurerm_storage_account" "storage" {
                name                     = "tfstate${random_string.suffix.result}"   # must be globally unique
                resource_group_name      = azurerm_resource_group.rg.name
                location                 = azurerm_resource_group.rg.location
                account_tier             = "Standard"
                account_replication_type = "LRS"
}


# Create a private container named 'tfstate' in the Azure Storage Account.
# This container will store the Terraform state file securely.
resource "azurerm_storage_container" "container" {
                name                  = "tfstate"
                storage_account_id    = azurerm_storage_account.storage.id
                container_access_type = "private"                         
}