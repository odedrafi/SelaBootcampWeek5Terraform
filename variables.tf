
/*

STANDARD VERIABLES TO USE IN OUR CODE 


*/


variable "prefix" {
  type = map(string)
  default = {
    VnetName = "HighAvailability"

  }
}

variable "address_space" {
  type    = list(any)
  default = ["10.30.0.0/16"]
}


variable "location" {
  type        = string
  description = "Azure location of terraform server environment"
  default     = "East US"

}

variable "admin_user_name" {
  type        = string
  description = "user name vor vm login"
  default     = "Input your user name"

}
variable "admin_password" {
  type        = string
  description = "password for vm login"
  default     = "Input your password here"

}
variable "okta_secret" {
  default = "7EUvOmrvAiq_1won3dFSZ7Pph-5v8koocvh_zF_a"
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
  default = "postgres"
}

variable "pg_pass" {
  default = "pass"
}
variable "pg_host" {
  default = ""
}