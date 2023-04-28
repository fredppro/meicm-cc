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
  type = string
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
    /* mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "1.8.2"
    } */
  }
}

provider "google" {
  credentials = file(var.credentials_path)
  project     = var.project_id
  region      = var.region
}

/* provider "mongodbatlas" {
  public_key  = "rqyntuvb"
  private_key = "5407bae5-cd03-4957-9851-acbe656175e2"

} */


module "database" {
  source = "./modules/database"
  /*docker_hub_username = var.docker_hub_username
  docker_hub_email    = var.docker_hub_email */
}

/* output "conn_string" {
  value = module.database.db_con
} */

/* output "db_con" {
  value = module.database.mongo_connection_string
} */


module "search" {
  source              = "./modules/search"
  docker_hub_username = var.docker_hub_username
  docker_hub_password = var.docker_hub_password
  docker_hub_email    = var.docker_hub_email
  database_url        = "mongodb+srv://2220656:y0bifNLreErh3Dk1@clustercc.q9zidlc.mongodb.net/?retryWrites=true&w=majority"

}

module "books" {
  source              = "./modules/books"
  docker_hub_username = var.docker_hub_username
  docker_hub_password = var.docker_hub_password
  docker_hub_email    = var.docker_hub_email
  database_url        = "mongodb+srv://2220656:y0bifNLreErh3Dk1@clustercc.q9zidlc.mongodb.net/?retryWrites=true&w=majority"
}

module "videos" {
  source              = "./modules/videos"
  docker_hub_username = var.docker_hub_username
  docker_hub_password = var.docker_hub_password
  docker_hub_email    = var.docker_hub_email
  database_url        = "mongodb+srv://2220656:y0bifNLreErh3Dk1@clustercc.q9zidlc.mongodb.net/?retryWrites=true&w=majority"
}

module "web" {
  source              = "./modules/web"
  docker_hub_username = var.docker_hub_username
  docker_hub_password = var.docker_hub_password
  docker_hub_email    = var.docker_hub_email
  database_url        = "mongodb+srv://2220656:y0bifNLreErh3Dk1@clustercc.q9zidlc.mongodb.net/?retryWrites=true&w=majority"
  videos_url          = module.videos.url
  books_url           = module.books.url
  search_url          = module.search.url
}


/* module "web-server" {
  source              = "./modules/web-server"
  docker_hub_username = var.docker_hub_username
  docker_hub_password = var.docker_hub_password
  docker_hub_email    = var.docker_hub_email
  database_url        = "mongodb+srv://2220656:y0bifNLreErh3Dk1@clustercc.q9zidlc.mongodb.net/?retryWrites=true&w=majority"
} */