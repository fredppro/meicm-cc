variable "docker_hub_username" {
  type    = string
  default = "fredppro"
}
variable "docker_hub_password" {
  type = string
}
variable "docker_hub_email" {
  type    = string
  default = "fredp.profissional@gmail.com"
}
variable "credentials_path" {
  type    = string
  # default = "./meicm-cc-1stproject-82167cf1e179.json"
  # default = "./meicm-cc-1stproject-3139988919aa.json"
  default = "./meicm-cc-1stproject-89900d452f14.json"
}
variable "project_id" {
  type    = string
  default = "meicm-cc-1stproject"
}
variable "region" {
  type    = string
  default = "us-central1"
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.58.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_path)
  project     = var.project_id
  region      = var.region
}


module "database" {
  source              = "./modules/database"
  docker_hub_username = var.docker_hub_username
  docker_hub_email    = var.docker_hub_email
}

output "teste" {
  value = module.database.db_module
}

/* module "web" {
  source              = "./modules/web"
  docker_hub_username = var.docker_hub_username
  docker_hub_password = var.docker_hub_password
  docker_hub_email    = var.docker_hub_email
  database_url        = module.database.env_db_var
}

module "search" {
  source              = "./modules/search"
  docker_hub_username = var.docker_hub_username
  docker_hub_password = var.docker_hub_password
  docker_hub_email    = var.docker_hub_email
  database_url        = module.database.env_db_var

} */

module "books" {
  source              = "./modules/books"
  docker_hub_username = var.docker_hub_username
  docker_hub_password = var.docker_hub_password
  docker_hub_email    = var.docker_hub_email
  database_url        = module.database.db_module
} 

/* module "videos" {
  source              = "./modules/videos"
  docker_hub_username = var.docker_hub_username
  docker_hub_password = var.docker_hub_password
  docker_hub_email    = var.docker_hub_email
  database_url        = module.database.db_module
} 


 module "web-server" {
  source              = "./modules/web-server"
  docker_hub_username = var.docker_hub_username
  docker_hub_password = var.docker_hub_password
  docker_hub_email    = var.docker_hub_email
  database_url        = module.database.env_db_var
} */
