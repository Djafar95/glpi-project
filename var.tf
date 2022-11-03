#####################################################
## Resource Groups
#####################################################

variable "var_rg_name" {
  default = "SUEZ-WEEU-GLPI-dev-RG01"
}

#####################################################
## Location
#####################################################

variable "var_location" {
  default = "westeurope"
}

#####################################################
## Storage Account 
#####################################################

variable "var_sa_name" {
  default = "saweeuaz01"
}
variable "var_sa_tier" {
  default = "Standard"
}
variable "var_sc_name" {
  default = "scweeuaz01"
}

#####################################################
## Commands
#####################################################

/* variable "var_vm_ansible_commands" {
  default = "wget https://${var_sa_name}.blob.core.windows.net/${var_sc_name}/ansible.sh && chmod +x ansible.sh && sh ansible.sh"
}
 */

#####################################################
## Tags
#####################################################

variable "var_tags" {
  default = {
    "app_environment"   = "Recette",
    "app_project_name"  = "SUEZ.GLPI",
    "app_creation_date" = "2022-11-03"
  }
}

#####################################################
## KeyVault
#####################################################

variable "var_kv_name" {
  default = "kvweeuaz01"
}
variable "var_disk_encryption" {
  default = "true"
}
variable "var_purge_protection" {
  default = "false"
}
variable "var_sku_name" {
  default = "standard"
}

#####################################################
## VM ANSIBLE (LINUX)
#####################################################

variable "var_vm_ansible_name" {
  default = "uxweeu-ans-dev"
}
variable "var_vm_ansible_size" {
  default = "Standard_D4s_v3"
}

#####################################################
## VM GLPI (WINDOWS)
#####################################################

variable "var_vm_glpi_name" {
  default = "wiweeu-glpi-dev"
}
variable "var_vm_glpi_size" {
  default = "Standard_F2"
}