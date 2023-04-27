/* variable "docker_hub_username" {
  type    = string
  default = "fredppro"
}
variable "docker_hub_email" {
  type    = string
  default = "fredp.profissional@gmail.com"
}

variable "port" {
  type    = number
  default = 27017
}


resource "google_cloud_run_v2_service" "mongodb" {
  name     = "mongodb"
  location = "us-central1"

  template {
    containers {
      image = "mongo:latest"
      ports {
        container_port = var.port
      }
    }
  }
}

output "env_db_var" {
  value = google_cloud_run_v2_service.mongodb.id
}

output "db_module" {
  value = google_cloud_run_v2_service.mongodb.uri
}

data "google_iam_policy" "admin" {
  binding {
    role = "roles/editor"
    members = [
      "allUsers"
    ]
  }
}

resource "google_cloud_run_v2_service_iam_policy" "policy" {
  project     = google_cloud_run_v2_service.mongodb.project
  location    = google_cloud_run_v2_service.mongodb.location
  name        = google_cloud_run_v2_service.mongodb.name
  policy_data = data.google_iam_policy.admin.policy_data
} */

/* terraform {
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "1.8.2"
    }
  }
}

resource "mongodbatlas_cluster" "cluster-test" {
  project_id   = "644adb2efb17803a9678f2cb"
  name         = "meicm-cc-1st"
  cluster_type = "REPLICASET"
  replication_specs {
    num_shards = 1
    regions_config {
      region_name     = "US_EAST_1"
      electable_nodes = 3
      priority        = 7
      read_only_nodes = 0
    }
  }
  cloud_backup                 = true
  auto_scaling_disk_gb_enabled = true
  mongo_db_major_version       = "4.2"

  # Provider Settings "block"
  provider_name               = "GCP"
  disk_size_gb                = 40
  provider_instance_size_name = "M30"
} */

/*resource "mongodbatlas_cluster" "cluster-test" {
  project_id              = "644adb2efb17803a9678f2cb"
  name                    = "cluster-test-global"

  # Provider Settings "block"
  provider_name = "GCP"
  backing_provider_name = "GCP"
  provider_region_name = "US_EAST_1"
  provider_instance_size_name = "M0"
} */

/* variable "public_key" {
  type        = string
  default     = "ofihonfl"
  description = "Public Programmatic API key to authenticate to Atlas"
}
variable "private_key" {
  type        = string
  default     = "89744a25-cbf7-481a-a27c-50447166181f"
  description = "Private Programmatic API key to authenticate to Atlas"
}
variable "org_id" {
  type        = string
  default     = "644abf59a0061b1df3bf31c8"
  description = "MongoDB Organization ID"
}
variable "project_name" {
  type        = string
  default     = "meicm-cc-1stproject"
  description = "The MongoDB Atlas Project Name"
}
variable "cluster_name" {
  type        = string
  default     = "ClusterTest"
  description = "The MongoDB Atlas Cluster Name"
}
variable "cloud_provider" {
  type        = string
  default     = "GCP"
  description = "The cloud provider to use, must be AWS, GCP or AZURE"
}
variable "region" {
  type        = string
  default     = "us-central1"
  description = "MongoDB Atlas Cluster Region, must be a region for the provider given"
}
variable "mongodbversion" {
  type        = string
  default     = "1"
  description = "The Major MongoDB Version"
}
variable "dbuser" {
  type        = string
  default     = "UserTest"
  description = "MongoDB Atlas Database User Name"
}
variable "dbuser_password" {
  type        = string
  default     = "12345678"
  description = "MongoDB Atlas Database User Password"
}
variable "database_name" {
  type        = string
  default     = "DefaultDB"
  description = "The database in the cluster to limit the database user to, the database does not have to exist yet"
}

variable "cidr" {
  type        = string
  default     = "0.0.0.0/0"
  description = "The CIDR range or AWS security group"
}

provider "mongodbatlas" {}

resource "mongodbatlas_project" "project" {
  name   = var.project_name
  org_id = var.org_id
}

resource "mongodbatlas_project_ip_access_list" "ip" {
  project_id = mongodbatlas_project.project.id
  # ip_address = var.ip_address
  cidr_block = var.cidr
  comment    = "IP Address for accessing the cluster"
}
resource "mongodbatlas_cluster" "cluster" {
  project_id             = mongodbatlas_project.project.id
  name                   = var.cluster_name
  mongo_db_major_version = var.mongodbversion
  cluster_type           = "REPLICASET"
  replication_specs {
    num_shards = 1
    regions_config {
      region_name     = var.region
      electable_nodes = 3
      priority        = 7
      read_only_nodes = 0
    }
  }
  # Provider Settings "block"
  cloud_backup                 = true
  auto_scaling_disk_gb_enabled = true
  provider_name                = var.cloud_provider
  provider_instance_size_name  = "M0"
}

resource "mongodbatlas_database_user" "user" {
  username           = var.dbuser
  password           = var.dbuser
  project_id         = mongodbatlas_project.project.id
  auth_database_name = "admin"

  roles {
    role_name     = "readWrite"
    database_name = var.database_name # The database name and collection name need not exist in the cluster before creating the user.
  }
  labels {
    key   = "Name"
    value = "DB User1"
  }
} 


output "mongo_connection_string" {
  value = mongodbatlas_cluster.cluster-test.connection_strings[0].standard
} */
