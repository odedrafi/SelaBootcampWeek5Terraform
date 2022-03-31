



locals {
  vars =  {
    HOST_URL = var.host_url
    OKTA_CLIENT_SECRET = var.okta_secret
    OKTA_CLIENT_ID = var.okta_client_id
    OKTA_ORG_URL = var.okta_org_url
    OKTA_KEY = var.okta_key
    PGUSERNAME = var.pg_user
    PGPASSWORD = var.pg_pass
    PGHOST = "${var.pg_host}.postgres.database.azure.com"
  }
}