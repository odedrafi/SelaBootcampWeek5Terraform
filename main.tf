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

/*----------------------------------------------------------------------------------------*/
# Azure Public Ip for Load Balancer
/*----------------------------------------------------------------------------------------*/
resource "azurerm_public_ip" "LoadBalacerPublicIp" {
  name                = "LoadBalacerPublicIp"
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  allocation_method   = "Static"
  sku                 = "Standard"
}
/*----------------------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------------------*/
# SIMPLE LOAD BALANCER BLOCK
/*----------------------------------------------------------------------------------------*/
resource "azurerm_lb" "App-LoadBalacer" {
  name                = "App-LoadBalacer"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "frontend-ip"
    public_ip_address_id = azurerm_public_ip.LoadBalacerPublicIp.id
  }


}
/*----------------------------------------------------------------------------------------*/


/*Configuring the load balncer inbound rule to allow outside access to the load balancer(Like a NSG)*/

 resource "azurerm_lb_rule" "AcceseRole" {
   resource_group_name            = azurerm_resource_group.RG.name
   loadbalancer_id                = azurerm_lb.App-LoadBalacer.id
   name                           = "LBRule"
   protocol                       = "Tcp"
   frontend_port                  = 8080
   backend_port                   = 8080
   frontend_ip_configuration_name = "frontend-ip"
   backend_address_pool_ids       = [azurerm_lb_backend_address_pool.AppScaleSet.id]
   probe_id                       = azurerm_lb_probe.Helthprobe.id
 }

/*----------------------------------------------------------------------------------------*/
#PROBE BLOCK REQUIRED FOR THE OPERATION OF LOAD BALNCER
/*----------------------------------------------------------------------------------------*/
resource "azurerm_lb_probe" "Helthprobe" {
  resource_group_name = azurerm_resource_group.RG.name
  loadbalancer_id     = azurerm_lb.App-LoadBalacer.id
  name                = "Helthprobe"
  port                = 8080
}
/*----------------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------------*/
#CREATING BACKEND POOL's FOR THE LOAD BALANCER
/*----------------------------------------------------------------------------------------*/
#Poll for Scale set "elastic" infrastracture
resource "azurerm_lb_backend_address_pool" "AppScaleSet" {
  loadbalancer_id = azurerm_lb.App-LoadBalacer.id
  name            = "AppScaleSet"
  depends_on = [
    azurerm_lb.App-LoadBalacer
  ]
}
/*----------------------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------------------*/
#BASTION SERVER BLOCK
#PROVIDING A SECURE WAY INTO OUR VIRTUAL NETWORK TO REACH THE VM'S AND DATA SERVERS
/*----------------------------------------------------------------------------------------*/
resource "azurerm_public_ip" "BastionPublicIp" {
  name                = "BastionPublicIp"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "BastionServer" {
  name                = "BastionServer"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.AzureBastionSubnet.id
    public_ip_address_id = azurerm_public_ip.BastionPublicIp.id
  }
}
/*----------------------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------------------*/
#NETWORK INTERFACES FOR THE POSTGRES DATA SERVER
/*----------------------------------------------------------------------------------------*/
resource "azurerm_network_interface" "PgDataServer" {
  name                = "PgDataServer-nic"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.Data_Tier.id
    private_ip_address_allocation = "Dynamic"

  }
}
/*----------------------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------------------*/
#THIS IS A LINUX VIRTUAL MACHINE FOR THE DATA BASE IT HAS SOME SPACIEL FUNCTIONALITYS 
#THAT ARE EXPLAIND IN DETAILE INSIDE THE BLOCK
/*----------------------------------------------------------------------------------------*/
resource "azurerm_linux_virtual_machine" "PgDataServer" {
  name                = "${var.prefix.PgDataServerName}-vm"
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  size                = "Standard_F2"
  /*---------required section choosing-----*/
  /*  to connect via user name and password  */
  /*--instead of the usuale ssh safer mathod----*/
  admin_username                  = var.admin_user_name
  admin_password                  = var.admin_password
  disable_password_authentication = false
  /*------------------------------------------------------*/
  network_interface_ids = [
    azurerm_network_interface.PgDataServer.id,
  ]

  /*---------------------------------------*/
  # this line run's a script with command line 
  #  that configurate the postgres server
  /*---------------------------------------*/
  custom_data = filebase64("DataServerRunUp.sh")

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
/*----------------------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------------------*/
# THIS IS A LINUX MACHINE SCALE SET FOR THE ELASTIC SOLUTION AGAIN THERE ARE SPECIEL FETURE'S
# THAT ARE DIFFERNT FROM THE MINIMUM STANDARD REQUIRMENTS AND THAT ARE CUSTOMED TO OUR NEEDS
/*----------------------------------------------------------------------------------------*/
resource "azurerm_linux_virtual_machine_scale_set" "AppScaleSet" {
  name                = "AppScaleSet"
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  sku                 = "Standard_F2"
  instances           = 2
  /*---------required section choosing-----*/
  /*  to connect via user name and password  */
  /*--instead of the usuale ssh safer mathod----*/
  admin_username                  = var.admin_user_name
  admin_password                  = var.admin_password
  disable_password_authentication = false
  /*---------------------------------------------*/

  # health_probe_id                 = azurerm_lb_probe.Helthprobe.id  ##not needed at the momment. uncomment if so
  upgrade_mode = "Automatic"


  /*---------------------------------------*/
  # this line run's a script with command line 
  #  that configurate the App on the instances 
  #              when created 
  /*---------------------------------------*/
  custom_data = filebase64("RunUp.sh")


  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "AppScaleSet-nic"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.Web_Tier.id

      /*  this line connects the scaile set to a backend pool      */
      /*  of the load balancer we want to hanlde th...well load :) */
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.AppScaleSet.id]
    }
  }
  lifecycle { 
    ignore_changes = [instances]
  }


}
/*----------------------------------------------------------------------------------------*/


