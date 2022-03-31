variable "VnetName" {
    default     = "Vnet"
    

}
variable "ScaleSetName" {
    default = "AppScaleSet"
    

}


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
variable azurerm_lb_backend_pool_Scale_set_module_id {

      type        = string

}
variable "okta_secret" {
    default = ""
}

variable "okta_client_id" {
    default = ""
}

variable "okta_org_url" {
    default = ""
}

variable "okta_key" {
    default = ""
}

variable "pg_user" {
    default = ""
}

variable "pg_pass" {
    default = ""
}

variable "host_url" {
    default = ""
}

variable "pg_host" {
    default = ""
}
variable "instance_num" {
    default = 2
}




