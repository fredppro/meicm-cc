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
  default = 3000
}

variable "database_url" {
  type    = string
  default = "https://mongodb-x7msqww2zq-uc.a.run.app"
}

/* module "database" {
  source = "../database"
} */


resource "null_resource" "videos_image" {
  provisioner "local-exec" {
    command = "docker buildx build --platform linux/amd64 -t ${local.docker_hub_username}/videos:1.0.0 ./videos"
  }

  provisioner "local-exec" {
    command = "docker login -u ${local.docker_hub_username} -p ${local.docker_hub_password} && docker push ${local.docker_hub_username}/videos:1.0.0"
  }

  triggers = {
    videos_version = "1.0.0"
  }
}

resource "google_cloud_run_v2_service" "videos" {
  name     = "videos"
  location = "us-central1"

  template {
    containers {
      image = "docker.io/${local.docker_hub_username}/videos:1.0.0"
      ports {
        container_port = var.port
      }
      /* startup_probe {
        initial_delay_seconds = 0
        timeout_seconds = 1
        period_seconds = 3
        failure_threshold = 1
        tcp_socket {
          port = 3003
        }
      }
      liveness_probe {
        http_get {
          path = "/"
        }
      }
      env {
        name  = "MONGO_DB_URI"
        value = "mongodb://${var.database_url}"
      }*/
    }
  }
  depends_on = [null_resource.videos_image, var.database_url]
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
  project     = google_cloud_run_v2_service.videos.project
  location    = google_cloud_run_v2_service.videos.location
  name        = google_cloud_run_v2_service.videos.name
  policy_data = data.google_iam_policy.admin.policy_data
} 

output "url" {
  value = google_cloud_run_v2_service.videos.uri
}