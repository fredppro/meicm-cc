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
variable "nginx_port" {
  default = "8080"
}

variable "nginx_root" {
  default = "/srv/www/static"
}

variable "nginx_proxy_api_search" {
  default = "http://search:3000"
}

variable "nginx_proxy_api_search_depends_on" {
  default = "http://search:3000"
}

variable "nginx_proxy_api_books" {
  default = "http://books:3000"
}

variable "nginx_proxy_api_videos" {
  default = "http://videos:3000"
}

data "template_file" "nginx_config" {
  template = file("${path.module}/nginx.conf.template")

  vars = {
    NGINX_PORT                      = var.nginx_port
    NGINX_ROOT                      = var.nginx_root
    NGINX_PROXY_API_SEARCH          = var.nginx_proxy_api_search
    NGINX_PROXY_API_SEARCH_DEPENDS_ON = var.nginx_proxy_api_search_depends_on
    NGINX_PROXY_API_BOOKS           = var.nginx_proxy_api_books
    NGINX_PROXY_API_VIDEOS          = var.nginx_proxy_api_videos
  }
}

resource "local_file" "nginx_config" {
  content  = data.template_file.nginx_config.rendered
  filename = "${path.module}/nginx.conf"
}



resource "google_cloud_run_v2_service" "nginx" {
  name     = "nginx"
  location = "us-central1"

  template {
    containers {
      image = "nginx:latest"
      ports {
        container_port = var.port
      }
    }
  }
}

resource "null_resource" "copy_file" {
  provisioner "local-exec" {
    command = <<-EOF
      # Authenticate to Google Cloud
      gcloud auth activate-service-account --key-file="./meicm-cc-1stproject-89900d452f14.json"

      # Copy the new Nginx configuration file to the Cloud Run container
      gcloud run services update web \
        --platform=managed \
        --region=us-central1 \
        --update-env-vars=NGINX_CONFIG="$(cat ${path.module}/nginx.conf)"
    EOF
  }
  depends_on = [google_cloud_run_v2_service.nginx]
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
  project     = google_cloud_run_v2_service.nginx.project
  location    = google_cloud_run_v2_service.nginx.location
  name        = google_cloud_run_v2_service.nginx.name
  policy_data = data.google_iam_policy.admin.policy_data
}
