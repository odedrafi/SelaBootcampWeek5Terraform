




output "password" {
  sensitive = true
  value     = azurerm_linux_virtual_machine_scale_set.AppScaleSet.admin_password #output the password for ci\cd
}