

resource "azurerm_public_ip" "AnsiblePuBLICIp" {
  name                = "AnsiblePuBLICIp"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "AnsibleNic" {
  name                = "AnsibleNic"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name

  ip_configuration {
    name                          = "AnsibleNicConfiguration"
    subnet_id                     = azurerm_subnet.Web_Tier.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.AnsiblePuBLICIp.id
  }
}

resource "azurerm_linux_virtual_machine" "Controller" {
  name                            = "Controller"
  location                        = azurerm_resource_group.RG.location
  resource_group_name             = azurerm_resource_group.RG.name
  network_interface_ids           = [azurerm_network_interface.AnsibleNic.id]
  size                            = "Standard_F2"#Standard_B1ls
  admin_username                  = var.admin_user_name
  admin_password                  = var.admin_password
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  tags = {
    name = var.tags
  }

}