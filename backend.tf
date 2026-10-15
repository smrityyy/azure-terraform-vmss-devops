terraform {
  backend "azurerm" {
    resource_group_name  = "backendrg"
    storage_account_name = "day14remotebackend"
    container_name       = "remotebackendcon"
    key                  = "dev.terraform.tfstate"
  }
}