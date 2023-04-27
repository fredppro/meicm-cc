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

variable "database_url" {
  type = string
}

variable "port" {
  type    = number
  default = 3000
}

/* module "database" {
  source = "../database"
} */


resource "null_resource" "web_image" {
  provisioner "local-exec" {
    command = "docker buildx build --platform linux/amd64 -t ${local.docker_hub_username}/web:1.0.0 ./web"
  }

  provisioner "local-exec" {
    command = "docker login -u ${local.docker_hub_username} -p ${local.docker_hub_password} && docker push ${local.docker_hub_username}/web:1.0.0"
  }

  triggers = {
    web_version = "1.0.0"
  }
}

resource "google_cloud_run_v2_service" "web" {
  name     = "web"
  location = "us-central1"

  template {
    containers {
      image = "docker.io/${local.docker_hub_username}/web:1.0.0"
      /* ports {
        container_port = var.port
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
  project = google_cloud_run_v2_service.web.project
  location = google_cloud_run_v2_service.web.location
  name = google_cloud_run_v2_service.web.name
  policy_data = data.google_iam_policy.admin.policy_data
}