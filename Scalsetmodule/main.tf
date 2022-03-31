
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }

  required_version = ">= 1.1.0"
}

/*----------------------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------------------*/
# THIS IS A LINUX MACHINE SCALE SET FOR THE ELASTIC SOLUTION AGAIN THERE ARE SPECIEL FETURE'S
# THAT ARE DIFFERNT FROM THE MINIMUM STANDARD REQUIRMENTS AND THAT ARE CUSTOMED TO OUR NEEDS
/*----------------------------------------------------------------------------------------*/
resource "azurerm_linux_virtual_machine_scale_set" "AppScaleSet" {
  name                = var.ScaleSetName
  resource_group_name = var.group_name
  location            = var.group_location
  sku                 = "Standard_F2"
  instances           = var.instance_num
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
  custom_data = base64encode(templatefile("./Scalsetmodule/RunUp.tftpl",local.vars))


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
      subnet_id = var.azurerm_subnet_id

      /*  this line connects the scaile set to a backend pool      */
      /*  of the load balancer we want to hanlde th...well load :) */
      load_balancer_backend_address_pool_ids = [var.azurerm_lb_backend_pool_Scale_set_module_id]
    }
  }
  lifecycle {
    ignore_changes = [instances]
  }


}
/*----------------------------------------------------------------------------------------*/