resource "azurerm_orchestrated_virtual_machine_scale_set" "vmss_terraform_tutorial" {
  depends_on = [
    azurerm_subnet_nat_gateway_association.example,
    azurerm_subnet_network_security_group_association.myNSG,
  ]

  timeouts {
    create = "20m"
  }

  name                        = "vmss-terraform"
  resource_group_name         = azurerm_resource_group.rg.name
  location                    = azurerm_resource_group.rg.location
  sku_name                    = "Standard_D2pds_v5"
  instances                   = 1
  platform_fault_domain_count = 1     # For zonal deployments, this must be set to 1
  zones                       = ["1"] # Zones required to lookup zone in the startup script

  user_data_base64 = base64encode(file("user-data.sh"))

  os_profile {
    linux_configuration {
      disable_password_authentication = true
      admin_username                  = "azureuser"
      admin_ssh_key {
        username   = "azureuser"
        public_key = var.ssh_public_key
      }
    }
  }

  # ARM64 image: required because Standard_D2pds_v5 is an Arm-based size
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-arm64"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "StandardSSD_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name                          = "nic"
    primary                       = true
    enable_accelerated_networking = false

    ip_configuration {
      name                                   = "ipconfig"
      primary                                = true
      subnet_id                              = azurerm_subnet.subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bepool.id]
    }
  }

  boot_diagnostics {
    storage_account_uri = ""
  }

  # Ignore changes to the instances property, so that the VMSS is not recreated when the number of instances is changed
  lifecycle {
    ignore_changes = [
      instances
    ]
  }
}