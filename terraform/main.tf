#Azure Provider Configuration
provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
  version         = "~> 1.36.0"
}

# Locate the existing custom image
data "azurerm_image" "search" {
  name                = "myPackerImage"
  resource_group_name = "resourcegroup"
}

output "image_id" {
  value = "/subscriptions/${var.subscription_id}/resourceGroups/resourcegroup/providers/Microsoft.Compute/images/myPackerImage"
}


# Create a virtual network - equivalent to VPC in aws
resource "azurerm_virtual_network" "vnetwork" {
  name                = "network"
  location            = "${var.location}"
  address_space       = ["${var.address_space}"]
  resource_group_name = "resourcegroup"
}


# Private subnet
resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = "resourcegroup"
  virtual_network_name = "${azurerm_virtual_network.vnetwork.name}"
  address_prefix       = "${var.address_space_1}"
}

resource "azurerm_subnet" "subnet2" {
  name                 = "subnet2"
  resource_group_name  = "resourcegroup"
  virtual_network_name = "${azurerm_virtual_network.vnetwork.name}"
  address_prefix       = "${var.address_space_2}"
}

resource "azurerm_subnet" "subnet3" {
  name                 = "subnet3"
  resource_group_name  = "resourcegroup"
  virtual_network_name = "${azurerm_virtual_network.vnetwork.name}"
  address_prefix       = "${var.address_space_3}"
}


#Create public Ip for VM
resource "azurerm_public_ip" "publicIp" {
  name                = "publicIp"
  location            = "${var.location}"
  resource_group_name = "resourcegroup"
  allocation_method   = "Dynamic"
}



#Security group for Virtual Machine
resource "azurerm_network_security_group" "vmsecurity" {
  name                = "vmsecurity"
  location            = "${var.location}"
  resource_group_name = "resourcegroup"

  security_rule {
    name                       = "test2"
    priority                   = 321
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "test1"
    priority                   = 320
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  


}

#Security groups for load balancer
resource "azurerm_application_security_group" "lbsecurity" {
  name                = "lbsecurity"
  location            = "${var.location}"
  resource_group_name = "resourcegroup"

}

#Network interface for subnets
resource "azurerm_network_interface" "example" {
  name                      = "networkInterface"
  location                  = "${var.location}"
  resource_group_name       = "resourcegroup"
  network_security_group_id = "${azurerm_network_security_group.vmsecurity.id}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.subnet2.id}"
    private_ip_address_allocation = "Dynamic"
  }
}


#Create Random Text for storage account
resource "random_id" "randomId" {
  keepers = {
    resource_group_name = "resourcegroup"
  }
  byte_length = 8
}

#Create Storage Account
resource "azurerm_storage_account" "mystorageaccount" {
  name                     = "${random_id.randomId.hex}stacc"
  resource_group_name      = "resourcegroup"
  location                 = "${var.location}"
  account_replication_type = "LRS"
  account_tier             = "Standard"

}

/*
#Create Virtual Machine
resource "azurerm_virtual_machine" "main" {
  name                  = "diag${random_id.randomId.hex}-myVM"
  location              = "${var.location}"
  resource_group_name   = "resourcegroup"
  network_interface_ids = ["${azurerm_network_interface.example.id}"]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true


  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    id = "${data.azurerm_image.search.id}"
  }
  storage_os_disk {
    name = "diag${random_id.randomId.hex}-osdisk"
    #managed_disk_id   = "${azurerm_managed_disk.osdisk.id}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "StandardSSD_LRS"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "pc"
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {   
            path     = "/home/pc/.ssh/authorized_keys"
            key_data = file("~/.ssh/azurekey.pub")
            
        }
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = "${azurerm_storage_account.mystorageaccount.primary_blob_endpoint}"
  }
}*/


#Create blob storage for Virtual Machine
resource "azurerm_storage_container" "container" {
  name                  = "content"
  storage_account_name  = "${azurerm_storage_account.mystorageaccount.name}"
  container_access_type = "private"
}

resource "azurerm_storage_blob" "blob" {
  name                   = "${var.codeDeployBucketName}"
  storage_account_name   = "${azurerm_storage_account.mystorageaccount.name}"
  storage_container_name = "${azurerm_storage_container.container.name}"
  type                   = "Block"

}

#######################################################################################


#RDS/SQL-database for VM

resource "azurerm_sql_server" "sqlServer" {
  name                         = "csye6225varad"
  resource_group_name          = "resourcegroup"
  location                     = "East US"
  version                      = "12.0"
  administrator_login          = "cyse6225"
  administrator_login_password = "projectvarad6225."
}

resource "azurerm_sql_database" "example" {
  name                = "mysqldbvarad"
  resource_group_name = "resourcegroup"
  location            = "East US"
  server_name         = "${azurerm_sql_server.sqlServer.name}"
}

#Create COSMOSDB(DocumentDB)
resource "azurerm_cosmosdb_account" "test" {
  name                = "${random_id.randomId.hex}-cosmosaccount"
  location            = "${var.location}"
  resource_group_name = "resourcegroup"
  offer_type          = "Standard"
  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 10
  }
  geo_location {
    location          = "${var.location}"
    failover_priority = 0
  }

}



#Lambda function creation
resource "azurerm_app_service_plan" "service_plan" {
  name                = "lambda-function-plan"
  location            = "${var.location}"
  resource_group_name = "resourcegroup"

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_function_app" "lambda_function" {
  name                      = "${random_id.randomId.hex}-lambdaFunction"
  location                  = "${var.location}"
  resource_group_name       = "resourcegroup"
  app_service_plan_id       = "${azurerm_app_service_plan.service_plan.id}"
  storage_connection_string = "${azurerm_storage_account.mystorageaccount.primary_connection_string}"

  app_settings = {

    FUNCTIONS_WORKER_RUNTIME = "java"
  }
}

#Create Monitor group
resource "azurerm_monitor_action_group" "monitorgroup" {
  name                = "${random_id.randomId.hex}-monitorGroup"
  resource_group_name = "resourcegroup"
  short_name          = "exampleact"
}

resource "azurerm_monitor_metric_alert" "alerting" {
  name                = "${random_id.randomId.hex}-alert"
  resource_group_name = "resourcegroup"
  scopes              = ["${azurerm_storage_account.mystorageaccount.id}"]
  description         = "Action will be triggered when Transactions count is greater than 50."

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "Transactions"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 50

    dimension {
      name     = "ApiName"
      operator = "Include"
      values   = ["*"]
    }
  }

  action {
    action_group_id = "${azurerm_monitor_action_group.monitorgroup.id}"
  }
}

#Create Load Balancer 
resource "azurerm_lb" "lb" {
  name                = "LoadBalancer"
  location            = "${var.location}"
  resource_group_name = "resourcegroup"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = "${azurerm_public_ip.publicIp.id}"
  }
}
resource "azurerm_lb_backend_address_pool" "addresspool" {
  resource_group_name = "resourcegroup"
  loadbalancer_id     = "${azurerm_lb.lb.id}"
  name                = "BackEndAddressPool"
}

resource "azurerm_lb_nat_pool" "natpool" {
  resource_group_name            = "resourcegroup"
  name                           = "ssh"
  loadbalancer_id                = "${azurerm_lb.lb.id}"
  protocol                       = "Tcp"
  frontend_port_start            = 50000
  frontend_port_end              = 50119
  backend_port                   = 22
  frontend_ip_configuration_name = "PublicIPAddress"
}


#Create Autoscaling 
resource "azurerm_virtual_machine_scale_set" "scaleset" {
  name                = "scaleset"
  location            = "${var.location}"
  resource_group_name = "resourcegroup"
  upgrade_policy_mode = "Automatic"

  sku {
    name     = "Standard_F2"
    tier     = "Standard"
    capacity = 2
  }
  storage_profile_image_reference {
    id      = "${data.azurerm_image.search.id}"
    version = "latest"
  }

  storage_profile_os_disk {
    os_type           = "linux"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name_prefix = "testingvm"
    admin_username       = "pc"
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
            path     = "/home/pc/.ssh/authorized_keys"
            key_data = file("~/.ssh/azurekey.pub")
            
     }
  }


  network_profile {
    name    = "networkprofile"
    primary = true

    ip_configuration {
      name                                   = "TestIPConfiguration"
      primary                                = true
      subnet_id                              = "${azurerm_subnet.subnet2.id}"
      load_balancer_backend_address_pool_ids = ["${azurerm_lb_backend_address_pool.addresspool.id}"]
      load_balancer_inbound_nat_rules_ids    = ["${azurerm_lb_nat_pool.natpool.id}"]
    }
  }

}

# Manages an AutoScale Setting which can be applied to Virtual Machine Scale Sets, 
#App Services and other scalable resources.

resource "azurerm_monitor_autoscale_setting" "autoscale" {
  name                = "autoscale"
  resource_group_name = "resourcegroup"
  location            = "${var.location}"
  target_resource_id  = "${azurerm_virtual_machine_scale_set.scaleset.id}"

  profile {
    name = "defaultProfile"

    capacity {
      default = 3
      minimum = 3
      maximum = 10
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = "${azurerm_virtual_machine_scale_set.scaleset.id}"
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 5
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = "${azurerm_virtual_machine_scale_set.scaleset.id}"
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 3
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }

  notification {
    email {
      send_to_subscription_administrator    = true
      send_to_subscription_co_administrator = true
      custom_emails                         = ["joshi.vara@husky.neu.edu"]
    }
  }
}

