variable group_name {
  type  = string
}
variable group_location{
    type  = string
}

variable admin_user_name{
    type  = string
  description = "user name vor vm login"

}
variable admin_password{

      type        = string
  description = "password for vm login"
}



variable azurerm_subnet_id{

      type        = string

}
variable azurerm_lb_backend_pool_AppScaleSet_id {

      type        = string

}


