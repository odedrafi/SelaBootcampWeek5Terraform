resource "azurerm_resource_group" "RG" {
  name     = "Week5ProjectNet"
  location = var.location
}



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
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.Scale_set_module.id]
  probe_id                       = azurerm_lb_probe.Helthprobe.id
  disable_outbound_snat          = true
}
resource "azurerm_lb_rule" "ssh" {
  resource_group_name            = azurerm_resource_group.RG.name
  loadbalancer_id                = azurerm_lb.App-LoadBalacer.id
  name                           = "ssh"
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = "frontend-ip"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.Scale_set_module.id]
  disable_outbound_snat          = true
}


resource "azurerm_lb_outbound_rule" "http" {
  resource_group_name     = azurerm_resource_group.RG.name
  loadbalancer_id         = azurerm_lb.App-LoadBalacer.id
  name                    = "http"
  protocol                = "Tcp"
  backend_address_pool_id = azurerm_lb_backend_address_pool.Scale_set_module.id
  frontend_ip_configuration {
    name = "frontend-ip"
  }

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
resource "azurerm_lb_backend_address_pool" "Scale_set_module" {
  loadbalancer_id = azurerm_lb.App-LoadBalacer.id
  name            = "Scale_set_module"
  depends_on = [
    azurerm_lb.App-LoadBalacer
  ]
}
/*----------------------------------------------------------------------------------------*/

module "Scale_set_module" {

  source = "./Scalsetmodule"

  group_name                                  = azurerm_resource_group.RG.name
  admin_user_name                             = var.admin_user_name
  admin_password                              = var.admin_password
  azurerm_subnet_id                           = azurerm_subnet.Web_Tier.id
  azurerm_lb_backend_pool_Scale_set_module_id = azurerm_lb_backend_address_pool.Scale_set_module.id
  group_location                              = azurerm_resource_group.RG.location
  host_url                                    = azurerm_public_ip.LoadBalacerPublicIp.ip_address
  pg_host                                     = azurerm_postgresql_flexible_server.PosrgreSQLFlexibleDataServer.name          /*"hakolzorem.postgres.database.azure.com"*/
  okta_org_url                                = var.okta_org_url
  okta_client_id                              = var.okta_client_id
  okta_secret                                 = var.okta_secret
  pg_user                                     = var.pg_user
  pg_pass                                     = var.pg_pass
  okta_key                                    = var.okta_key
  depends_on                                  = [azurerm_lb.App-LoadBalacer]
  instance_num                                = var.instance_num
  ScaleSetName                                = var.ScaleSetName
  VnetName                                    = var.VnetName
}






