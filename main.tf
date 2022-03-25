resource "azurerm_resource_group" "RG" {
  name     = "Week5ProjectNet"
  location = var.location
}


/*----------------------------------------------------------------------------------------*/
# Create a virtual network
/*----------------------------------------------------------------------------------------*/
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix.VnetName}-Net"
  address_space       = var.address_space
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
}
/*----------------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------------*/
# Creat a subnet for the data base
/*----------------------------------------------------------------------------------------*/
resource "azurerm_subnet" "Data_Tier" {
  name                 = "Data_Tier"
  resource_group_name  = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.30.2.0/24"]
}
/*----------------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------------*/
#subnet for our bastion server 
/*----------------------------------------------------------------------------------------*/
resource "azurerm_subnet" "AzureBastionSubnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.30.3.0/24"]
}
/*----------------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------------*/
# Creat a subnet for the app servers the web tier
/*----------------------------------------------------------------------------------------*/
resource "azurerm_subnet" "Web_Tier" {
  name                 = "Web_Tier"
  resource_group_name  = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.30.1.0/24"]
  # sku                 = "Standard"

}
/*----------------------------------------------------------------------------------------*/
