# module "vmscaleset" {
#   source  = "kumarvna/vm-scale-sets/azurerm"
#   version = "2.3.0"

#   # Resource Group and location, VNet and Subnet detials (Required)
#   resource_group_name  = "rg-shared-westeurope-01"
#   virtual_network_name = "vnet-shared-hub-westeurope-001"
#   subnet_name          = "snet-management"
#   vmscaleset_name      = "testvmss"

#   # This module support multiple Pre-Defined Linux and Windows Distributions.
#   # Check the README.md file for more pre-defined images for Ubuntu, Centos, RedHat.
#   # Please make sure to use gen2 images supported VM sizes if you use gen2 distributions
#   # Specify `disable_password_authentication = false` to create random admin password
#   # Specify a valid password with `admin_password` argument to use your own password 
#   # To generate SSH key pair, specify `generate_admin_ssh_key = true`
#   # To use existing key pair, specify `admin_ssh_key_data` to a valid SSH public key path.  
#   os_flavor               = "linux"
#   linux_distribution_name = "ubuntu1804"
#   virtual_machine_size    = "Standard_A2_v2"
#  admin_username                  = var.admin_user_name
#   admin_password                  = var.admin_password

#   disable_password_authentication = false
#   instances_count         = 2

#   enable_automatic_instance_repair    = true

#   # Public and private load balancer support for VM scale sets
#   # Specify health probe port to allow LB to detect the backend endpoint status
#   # Standard Load Balancer helps load-balance TCP and UDP flows on all ports simultaneously
#   # Specify the list of ports based on your requirement for Load balanced ports
#   # for additional data disks, provide the list for required size for the disk. 
#   load_balancer_type              = "public"
#   load_balancer_health_probe_port = 80
#   load_balanced_port_list         = [80, 443]
#   additional_data_disks           = [100, 200]
#  custom_data = filebase64("RunUp.sh")

#   # Enable Auto scaling feature for VM scaleset by set argument to true. 
#   # Instances_count in VMSS will become default and minimum instance count.
#   # Automatically scale out the number of VM instances based on CPU Average only.    
#   enable_autoscale_for_vmss          = true
#   minimum_instances_count            = 2
#   maximum_instances_count            = 5
#   scale_out_cpu_percentage_threshold = 80
#   scale_in_cpu_percentage_threshold  = 20

#   # Boot diagnostics to troubleshoot virtual machines, by default uses managed 
#   # To use custom storage account, specify `storage_account_name` with a valid name
#   # Passing a `null` value will utilize a Managed Storage Account to store Boot Diagnostics
#   enable_boot_diagnostics = true

#   # Network Seurity group port allow definitions for each Virtual Machine
#   # NSG association to be added automatically for all network interfaces.
#   # Remove this NSG rules block, if `existing_network_security_group_id` is specified
#   nsg_inbound_rules = [
#     {
#       name                   = "http"
#       destination_port_range = "80"
#       source_address_prefix  = "*"
#     },

#     {
#       name                   = "https"
#       destination_port_range = "443"
#       source_address_prefix  = "*"
#     },
#   ]

#   # (Optional) To enable Azure Monitoring and install log analytics agents
#   # (Optional) Specify `storage_account_name` to save monitoring logs to storage.   
#   log_analytics_workspace_id = data.azurerm_log_analytics_workspace.example.id

#   # Deploy log analytics agents to virtual machine. 
#   # Log analytics workspace customer id and primary shared key required.
#   deploy_log_analytics_agent                 = true
#   log_analytics_customer_id                  = data.azurerm_log_analytics_workspace.example.workspace_id
#   log_analytics_workspace_primary_shared_key = data.azurerm_log_analytics_workspace.example.primary_shared_key

#   # Adding additional TAG's to your Azure resources
#   tags = {
#     ProjectName  = "demo-project"
#     Env          = "dev"
#     Owner        = "user@example.com"
#     BusinessUnit = "CORP"
#     ServiceClass = "Gold"
#   }
# }
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
  name                = "AppScaleSet"
  resource_group_name = var.group_name
  location            = var.group_location
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
      subnet_id = var.azurerm_subnet_id

      /*  this line connects the scaile set to a backend pool      */
      /*  of the load balancer we want to hanlde th...well load :) */
      load_balancer_backend_address_pool_ids = [var.azurerm_lb_backend_pool_AppScaleSet_id]
    }
  }
  lifecycle {
    ignore_changes = [instances]
  }


}
/*----------------------------------------------------------------------------------------*/