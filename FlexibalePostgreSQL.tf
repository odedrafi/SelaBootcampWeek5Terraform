

resource "azurerm_private_dns_zone" "Flexibale_Postgres_DataBase_DNS" {
  name                = "Flexible.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.RG.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "DNS_Zone_VN_Link" {
  name                  = "exampleVnetZone.com"
  private_dns_zone_name = azurerm_private_dns_zone.Flexibale_Postgres_DataBase_DNS.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = azurerm_resource_group.RG.name
}

resource "azurerm_postgresql_flexible_server" "PosrgreSQLFlexibleDataServer" {
  name                   = "posrgresqldataserver"
  resource_group_name    = azurerm_resource_group.RG.name
  location               = azurerm_resource_group.RG.location
  version                = "12"
  delegated_subnet_id    = "/subscriptions/f7453106-f682-4e03-8ff3-f46f5676667d/resourceGroups/Week5ProjectNet/providers/Microsoft.Network/virtualNetworks/HighAvailability-Net/subnets/Data_Tier"
  private_dns_zone_id    = azurerm_private_dns_zone.Flexibale_Postgres_DataBase_DNS.id
  administrator_login    = "${var.pg_user}"
  administrator_password = "${var.pg_pass}"
  zone                   = "1"
  create_mode            = "Default"
  storage_mb             = 32768

  sku_name   = "GP_Standard_D4s_v3"
  depends_on = [azurerm_private_dns_zone_virtual_network_link.DNS_Zone_VN_Link]

}
resource "azurerm_postgresql_flexible_server_database" "db" {
  name      = "db"
  server_id = azurerm_postgresql_flexible_server.PosrgreSQLFlexibleDataServer.id
  collation = "en_US.utf8"
  charset   = "utf8"
}
resource "azurerm_postgresql_flexible_server_firewall_rule" "example" {
  name             = "example-fw"
  server_id        = azurerm_postgresql_flexible_server.PosrgreSQLFlexibleDataServer.id
  start_ip_address = "10.30.1.1"
  end_ip_address   = "10.30.1.200"
}


resource "azurerm_postgresql_flexible_server_configuration" "flexible_server_configuration" {
  name      = "backslash_quote"
  server_id = azurerm_postgresql_flexible_server.PosrgreSQLFlexibleDataServer.id
  value     = "off"
}