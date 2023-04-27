terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
    google = {
      source  = "hashicorp/google"
      version = "4.58.0"
    }
  }
}

provider "docker" {}

provider "google" {
  credentials = file("meicm-cc-1stproject-82167cf1e179.json")
  region      = "us-central1"
  zone        = "us-central1-c"
  project     = "meicm-cc-1stproject"
}

resource "docker_network" "app_network" {
  name = "app_network"
}

resource "docker_container" "mongodb" {
  name  = "mongodb"
  image = "mongo:latest"
  ports {
    internal = 27017
    external = 27017
  }

  network_mode = docker_network.app_network.name

  # network_mode = docker_network.app_network.name

  restart = "always"
}

# Docker images for each service
resource "docker_image" "web_service" {
  name = "fredppro/web_service"
  build {
    context    = "./web"
    dockerfile = "./Dockerfile"
  }
}

resource "docker_image" "search_service" {
  name = "fredppro/search_service"
  build {
    context    = "./search"
    dockerfile = "./Dockerfile"
  }
}

resource "docker_image" "books_service" {
  name = "fredppro/books_service"
  build {
    context    = "./books"
    dockerfile = "./Dockerfile"
  }
}

resource "docker_image" "videos_service" {
  name = "fredppro/videos_service"
  build {
    context    = "./videos"
    dockerfile = "./Dockerfile"
  }
}

# Docker containers for each service
resource "docker_container" "web_service_container" {
  name  = "web"
  image = docker_image.web_service.name
  ports {
    internal = 3000
    external = 3000
  }
  # network_mode = docker_network.app_network.name
  network_mode = docker_network.app_network.name

  depends_on = [docker_container.mongodb]
  env        = ["MONGO_DB_URI=mongodb://mongodb/microservices"]
}

resource "docker_container" "search_service_container" {
  name  = "search"
  image = docker_image.search_service.name
  ports {
    internal = 3000
    external = 3001
  }
  network_mode = docker_network.app_network.name
  depends_on   = [docker_container.mongodb]
  env          = ["MONGO_DB_URI=mongodb://mongodb/microservices"]
}

resource "docker_container" "books_service_container" {
  name  = "books"
  image = docker_image.books_service.name
  ports {
    internal = 3000
    external = 3002
  }
  network_mode = docker_network.app_network.name
  depends_on   = [docker_container.mongodb]
  env          = ["MONGO_DB_URI=mongodb://mongodb/microservices"]
}

resource "docker_container" "videos_service_container" {
  name  = "videos"
  image = docker_image.videos_service.name
  ports {
    internal = 3000
    external = 3003
  }
  network_mode = docker_network.app_network.name
  depends_on   = [docker_container.mongodb]
  env          = ["MONGO_DB_URI=mongodb://mongodb/microservices"]
}


# Bash script to generate Nginx configuration file with IP addresses of each service container
resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = false
}


resource "docker_container" "nginx" {
  image = "nginx:latest"
  name  = "nginx"

  ports {
    internal = 8080
    external = 8080
  }

  network_mode = docker_network.app_network.name

  depends_on = [
    docker_container.books_service_container,
    docker_container.videos_service_container,
    docker_container.search_service_container,
    docker_container.web_service_container,
  ]
}

resource "null_resource" "copy_file" {
  depends_on = [docker_container.nginx]

  provisioner "local-exec" {
    command = <<EOT
      docker cp ${path.cwd}/default.conf ${docker_container.nginx.name}:/etc/nginx/conf.d/default.conf
      docker exec ${docker_container.nginx.name} nginx -s reload
    EOT
  }

}






