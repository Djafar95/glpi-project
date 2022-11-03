
Voici ce qui a été jusqu'à présent automatisé par Terraform :
- Déploiement de l'infrastructure composée de 
	- 1 VM Linux (Ansible)
	- 1 VM Windows (GLPI)
	- 1 VNET et 2 subnets (Front et Back)
	- 1 Key Vault pour stocker les mots de passe des VM
	- 1 Compte de stockage pour stocker les scripts de configuration (installation d'Ansible)
	
	
Le déploiement de l'infrastructure nécessite quelques ajustements afin que vous puissiez la déployer de votre côté :	

#####
#Créer un fichier provider.tf avec les informations de votre souscription 

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.29.1"
    }

    # Random Provider
    random = {
      source  = "hashicorp/random"
      version = "= 3.4.3"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "xxxxxxxxxxxx"
  client_id       = "xxxxxxxxxxxx"
  client_secret   = "xxxxxxxxxxxx"
  tenant_id       = "xxxxxxxxxxxx"
}


#####
#Créer un fichier sensitive-data.tf avec les informations vous concernant
variable "var_tenant_id" {
  default = "xxxxxxxxxxxx" #Votre Tenant ID d'Azure
}

variable "var_sp_terraform" {
  default = "xxxxxxxxxxxx" #ObjectId du SPN permettant de déployer les ressources sur Azure
}



#####
#Dans le fichier DeployArchi.tf
Ligne 29, définir l'IP publique utilisée pour déployer l'infrastructure



Suite à la deadline que nous nous étions fixé, je n'ai pas eu le temps de tout finaliser. Il me reste :
- création du playbook ansible et configuration du fichier /ansible/hosts
- installation de GLPI sur la machine Windows 