terraform {

required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.35.0"
    }
  }
  ## Storage Account - Remote Storage for deploying and backing up Terraform infra (Azure project)
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstatelyfuf4"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}


provider "azurerm" {
  # Configuration options

  features {
    
  }
  subscription_id = "" ## your azure subscription id
  
}


##Create A Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-pvaks-demo"
  location = "East US"
}



