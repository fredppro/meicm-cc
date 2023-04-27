variable "docker_hub_username" {
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
      "serviceAccount:253219326140-compute@developer.gserviceaccount.com"
    ]
  }
}

resource "google_cloud_run_v2_service_iam_policy" "policy" {
  project = google_cloud_run_v2_service.mongodb.project
  location = google_cloud_run_v2_service.mongodb.location
  name = google_cloud_run_v2_service.mongodb.name
  policy_data = data.google_iam_policy.admin.policy_data
}