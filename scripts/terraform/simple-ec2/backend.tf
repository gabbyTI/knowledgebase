terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-backend"
    storage_account_name = "ibenyestorageaccount"
    container_name       = "backendcontainer"
    key                  = "knowledgebase/simple-ec2/terraform.tfstate"
  }
}