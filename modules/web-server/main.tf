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

variable "port" {
  type    = number
  default = 8080
}

variable "database_url" {
  type = string
}

/* module "database" {
  source = "../database"
} */


resource "google_cloud_run_v2_service" "nginx" {
  name     = "nginx"
  location = "us-central1"

  template {
    containers {
      image = "nginx:latest"
      /* ports {
        container_port = var.port
      } 
      startup_probe {
        initial_delay_seconds = 0
        timeout_seconds = 1
        period_seconds = 3
        failure_threshold = 1
        tcp_socket {
          port = 8080
        }
      }
      liveness_probe {
        http_get {
          path = "/"
        }
      } */
      env {
        name  = "MONGO_DB_URI"
        value = "mongodb://${var.database_url}/microservices"
      }
    }
  }
  depends_on = [var.database_url]
}

locals {
  backend_version     = "1.0.0"
  docker_hub_username = var.docker_hub_username
  docker_hub_password = var.docker_hub_password
  docker_hub_email    = var.docker_hub_email
}

data "google_iam_policy" "admin" {
  binding {
    role = "roles/editor"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_v2_service_iam_policy" "policy" {
  project = google_cloud_run_v2_service.nginx.project
  location = google_cloud_run_v2_service.nginx.location
  name = google_cloud_run_v2_service.nginx.name
  policy_data = data.google_iam_policy.admin.policy_data
}