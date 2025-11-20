// Tags
locals {
  tags = {
    class      = var.tag_class
    instructor = var.tag_instructor
    semester   = var.tag_semester
  }
}

// Existing Resources

/// Subscription ID
# data "azurerm_subscription" "current" {
# }

// Random Suffix Generator
resource "random_integer" "deployment_id_suffix" {
  min = 100
  max = 999
}

// Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.class_name}-${var.student_name}-${var.environment}-${var.location}-${random_integer.deployment_id_suffix.result}"
  location = var.location

  tags = local.tags
}

// Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.class_name}-${var.student_name}-${var.environment}-${random_integer.deployment_id_suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  address_space = ["10.0.0.0/16"]

  tags = local.tags
}

// Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-${var.class_name}-${var.student_name}-${var.environment}-${random_integer.deployment_id_suffix.result}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  address_prefixes = ["10.0.1.0/24"]

  service_endpoints = [
    "Microsoft.Sql",
    "Microsoft.Storage"
  ]
}

// Storage Account
resource "azurerm_storage_account" "storage" {
  name                     = "sto${var.class_name}${var.student_name}${var.environment}${random_integer.deployment_id_suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true

  allow_nested_items_to_be_public = false

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
    virtual_network_subnet_ids = [
      azurerm_subnet.subnet.id
    ]
  }

  tags = local.tags
}

// MSSQL Server
resource "azurerm_mssql_server" "sql" {
  name                = "sql-${var.class_name}-${var.student_name}-${var.environment}-${random_integer.deployment_id_suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  version                      = "12.0"
  administrator_login          = "4dm1n157r470r"
  administrator_login_password = "4-v3ry-53cr37-p455w0rd"
  minimum_tls_version          = "1.2"

  tags = local.tags
}

// MSSQL Database
resource "azurerm_mssql_database" "db" {
  name      = "sqldb-${var.class_name}-${var.student_name}-${var.environment}-${random_integer.deployment_id_suffix.result}"
  server_id = azurerm_mssql_server.sql.id

  collation   = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb = 2
  sku_name    = "Basic"

  tags = local.tags
}

// MSSQL VNet Rule
resource "azurerm_mssql_virtual_network_rule" "sql_vnet_rule" {
  name      = "sqlvnetrule-${var.class_name}-${var.student_name}-${var.environment}-${random_integer.deployment_id_suffix.result}"
  server_id = azurerm_mssql_server.sql.id
  subnet_id = azurerm_subnet.subnet.id

  depends_on = [
    azurerm_subnet.subnet
  ]
}
