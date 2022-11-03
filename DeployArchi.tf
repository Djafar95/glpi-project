#####################################################
## Resource Groups
#####################################################

resource "azurerm_resource_group" "glpi-dev-rg" {
  name     = var.var_rg_name
  location = var.var_location

  tags = {
    app_environment   = var.var_tags.app_environment
    app_project_name  = var.var_tags.app_project_name
    app_creation_date = var.var_tags.app_creation_date
  }
}

#####################################################
## Storage Account && blob
#####################################################

resource "azurerm_storage_account" "suez-weeu-sa-dev" {
  name                     = var.var_sa_name
  resource_group_name      = azurerm_resource_group.glpi-dev-rg.name
  location                 = azurerm_resource_group.glpi-dev-rg.location
  account_tier             = var.var_sa_tier
  account_replication_type = "LRS"

  network_rules {
    default_action = "Deny"
    ip_rules = ["90.91.101.4"]
    virtual_network_subnet_ids = [
      azurerm_subnet.suez-weeu-glpi-dev-subnet-front.id,
      azurerm_subnet.suez-weeu-glpi-dev-subnet-back.id,
    ]
  }

  tags = {
    app_environment   = var.var_tags.app_environment
    app_project_name  = var.var_tags.app_project_name
    app_creation_date = var.var_tags.app_creation_date
  }
}

resource "azurerm_storage_container" "suez-weeu-sc-dev" {
  name                  = var.var_sc_name
  storage_account_name  = azurerm_storage_account.suez-weeu-sa-dev.name
  container_access_type = "blob"
}

resource "azurerm_storage_blob" "suez-weeu-blob-dev" {
  name                   = "ansible.sh"
  storage_account_name   = azurerm_storage_account.suez-weeu-sa-dev.name
  storage_container_name = azurerm_storage_container.suez-weeu-sc-dev.name
  type                   = "Block"
  source                 = "./ansible.sh"
}

#####################################################
## KeyVault
#####################################################

resource "azurerm_key_vault" "suez-weeu-kv-dev" {
  name                        = var.var_kv_name
  location                    = azurerm_resource_group.glpi-dev-rg.location
  resource_group_name         = azurerm_resource_group.glpi-dev-rg.name
  enabled_for_disk_encryption = var.var_disk_encryption
  tenant_id                   = var.var_tenant_id
  purge_protection_enabled    = var.var_purge_protection

  sku_name = var.var_sku_name

  access_policy {
    tenant_id = var.var_tenant_id
    object_id = var.var_sp_terraform

    key_permissions = [
      "Get"
    ]

    secret_permissions = [
      "Get","Backup", "Delete", "List", "Purge", "Recover", "Restore", "Set"
    ]

    storage_permissions = [
      "Get"
    ]
  }
}

#####################################################
## Password
#####################################################

# Create random password for GLPI VM
resource "random_password" "glpi-vm-secret" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
resource "azurerm_key_vault_secret" "suez-weeu-glpi-vm-admin-secret" {
  name         = "${var.var_vm_glpi_name}-suez-admin-secret"
  value        = random_password.glpi-vm-secret.result
  key_vault_id = azurerm_key_vault.suez-weeu-kv-dev.id
}

# Create random password for ANSIBLE VM
resource "random_password" "ansible-vm-secret" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
resource "azurerm_key_vault_secret" "suez-weeu-ansible-vm-admin-secret" {
  name         = "${var.var_vm_ansible_name}-suez-admin-secret"
  value        = random_password.ansible-vm-secret.result
  key_vault_id = azurerm_key_vault.suez-weeu-kv-dev.id
}

#####################################################
## Virtual Network && Subnet 
#####################################################

#Vnet
resource "azurerm_virtual_network" "suez-weeu-glpi-dev-vnet" {
  name                = "SUEZ-WEEU-GLPI-dev-VN01"
  location            = azurerm_resource_group.glpi-dev-rg.location
  resource_group_name = azurerm_resource_group.glpi-dev-rg.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    app_environment   = var.var_tags.app_environment
    app_project_name  = var.var_tags.app_project_name
    app_creation_date = var.var_tags.app_creation_date
  }
}

#Subnet Front
resource "azurerm_subnet" "suez-weeu-glpi-dev-subnet-front" {
  name                 = "SUEZ-WEEU-GLPI-dev-SN-FRONT"
  resource_group_name  = azurerm_resource_group.glpi-dev-rg.name
  virtual_network_name = azurerm_virtual_network.suez-weeu-glpi-dev-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = ["Microsoft.Storage", "Microsoft.KeyVault"]
}

#Subnet Back
resource "azurerm_subnet" "suez-weeu-glpi-dev-subnet-back" {
  name                 = "SUEZ-WEEU-GLPI-dev-SN-BACK"
  resource_group_name  = azurerm_resource_group.glpi-dev-rg.name
  virtual_network_name = azurerm_virtual_network.suez-weeu-glpi-dev-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = ["Microsoft.Storage", "Microsoft.KeyVault"]
}

#####################################################
## VM ANSIBLE
#####################################################

#NIC 
resource "azurerm_network_interface" "suez-weeu-ansible-dev-nic" {
  name                = "${var.var_vm_ansible_name}-nic"
  location            = var.var_location
  resource_group_name = azurerm_resource_group.glpi-dev-rg.name

  ip_configuration {
    name                          = "${var.var_vm_ansible_name}-config"
    subnet_id                     = azurerm_subnet.suez-weeu-glpi-dev-subnet-back.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.suez-weeu-ansible-dev-pip.id
  }

  tags = {
    app_environment   = var.var_tags.app_environment
    app_project_name  = var.var_tags.app_project_name
    app_creation_date = var.var_tags.app_creation_date
    app_name          = "ansible"
  }
}

# Public IP
resource "azurerm_public_ip" "suez-weeu-ansible-dev-pip" {
  name                = "${var.var_vm_ansible_name}-pip"
  location            = var.var_location
  resource_group_name = azurerm_resource_group.glpi-dev-rg.name
  allocation_method   = "Dynamic"
}

# VM
resource "azurerm_linux_virtual_machine" "suez-weeu-ansible-dev-vm" {
  name                  = var.var_vm_ansible_name
  location              = var.var_location
  resource_group_name   = azurerm_resource_group.glpi-dev-rg.name
  network_interface_ids = [azurerm_network_interface.suez-weeu-ansible-dev-nic.id]
  size                  = var.var_vm_ansible_size
  admin_username        = "adminsuez"
  admin_password        = azurerm_key_vault_secret.suez-weeu-ansible-vm-admin-secret.value
  provision_vm_agent              = true
  disable_password_authentication = false

  os_disk {
    name                 = "${var.var_vm_ansible_name}-OsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = {
    app_environment   = var.var_tags.app_environment
    app_project_name  = var.var_tags.app_project_name
    app_creation_date = var.var_tags.app_creation_date
    app_name          = "ansible"
  }
}

#VM Extension
resource "azurerm_virtual_machine_extension" "suez-weeu-ansible-dev-vm-ext" {
  name                 = "CustomScriptExtension"
  virtual_machine_id   = azurerm_linux_virtual_machine.suez-weeu-ansible-dev-vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

    settings = <<SETTINGS
 {
  "commandToExecute": "cd /tmp/ && wget https://${var.var_sa_name}.blob.core.windows.net/${var.var_sc_name}/ansible.sh && chmod +x ansible.sh && sh ansible.sh"
 }
SETTINGS
}

#####################################################
## VM GLPI
#####################################################

#NIC 
resource "azurerm_network_interface" "suez-weeu-glpi-dev-nic" {
  name                = "${var.var_vm_glpi_name}-nic"
  location            = var.var_location
  resource_group_name = azurerm_resource_group.glpi-dev-rg.name

  ip_configuration {
    name                          = "${var.var_vm_glpi_name}-config"
    subnet_id                     = azurerm_subnet.suez-weeu-glpi-dev-subnet-front.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.suez-weeu-glpi-dev-pip.id
  }

  tags = {
    app_environment   = var.var_tags.app_environment
    app_project_name  = var.var_tags.app_project_name
    app_creation_date = var.var_tags.app_creation_date
    app_name          = "glpi"
  }
}

# Public IP
resource "azurerm_public_ip" "suez-weeu-glpi-dev-pip" {
  name                = "${var.var_vm_glpi_name}-pip"
  location            = var.var_location
  resource_group_name = azurerm_resource_group.glpi-dev-rg.name
  allocation_method   = "Dynamic"
}

#VM
resource "azurerm_windows_virtual_machine" "suez-weeu-glpi-dev-vm" {
  name                  = var.var_vm_glpi_name
  resource_group_name   = azurerm_resource_group.glpi-dev-rg.name
  location              = var.var_location
  size                  = var.var_vm_glpi_size
  admin_username        = "adminsuez"
  admin_password        = azurerm_key_vault_secret.suez-weeu-glpi-vm-admin-secret.value
  network_interface_ids = [azurerm_network_interface.suez-weeu-glpi-dev-nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}