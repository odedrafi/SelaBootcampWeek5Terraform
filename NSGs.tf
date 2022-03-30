# for more readable tamplate we devide as much as possible 
# this section is for the network security groups we need 

/*----------------------------------------------------------------------------------------*/
# A NETWORK SECURITY GROUP PLUS AN ASSOSIATION TO THE WEB TIER SUBNET 
# this network security group will have the azure standard plus an openning of port 8080 
#  to startlistaning for app request 
/*----------------------------------------------------------------------------------------*/
resource "azurerm_subnet_network_security_group_association" "NSG1" {
  subnet_id                 = azurerm_subnet.Web_Tier.id
  network_security_group_id = azurerm_network_security_group.NSG1.id
}

resource "azurerm_network_security_group" "NSG1" {
  name                = "NSG1"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
  security_rule {
    name                       = "ssh"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "79.178.9.59"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allow_8080"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

/*----------------------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------------------*/
/* A NETWORK SECURITY GROUP PLUS AN ASSOSIATION TO THE DATA TIER SUBNET                   */
/*----------------------------------------------------------------------------------------*/
resource "azurerm_subnet_network_security_group_association" "NSG2_association" {
  subnet_id                 = azurerm_subnet.Data_Tier.id
  network_security_group_id = azurerm_network_security_group.NSG2.id


}
/* BECAUSE WE WANT THE DATA TIER TO REMAINE "HIDDEN" TO OUTSIDE EYES WE CAN LEAVE THE STANDARD  */
/* AZURE NSG BLOCK THAT ALLOWS ONLY INSIDE NETWORK COMUNICATIONS                                */
resource "azurerm_network_security_group" "NSG2" {
  name                = "NSG2"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name

  security_rule {
    name                       = "Postgres"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "5432"
    destination_port_range     = "5432"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

}
/*----------------------------------------------------------------------------------------*/
