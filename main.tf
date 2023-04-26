terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

provider "docker" {}

resource "docker_network" "app_network" {
  name = "app_network"
}

# Create a Docker network for your microservices to communicate with each other
# resource "docker_network" "app_network" {
#   name   = "app_network"
#   driver = "bridge"
#   ipam_config {
#     subnet = "172.16.0.0/24"
#   }
# }

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

/* resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "tutorial"
  ports {
    internal = 80
    external = 8080
  }

  # command = ["nginx", "-g", "daemon off;"]

  # command = ["nginx", "-g", "daemon off;", "sudo echo 'server { listen 8080; listen [::]:80; root /srv/www/static; server_name localhost; #access_log /var/log/nginx/host.access.log main; location / { # We try to get static files from nginx first # because node is not great at IO operations try_files $uri $uri/ @web; } location @web { proxy_pass http://web:3000; } location /api/v1/search { proxy_pass http://search:3000; } location /api/v1/search/depends-on { proxy_pass http://search:3000; } location /api/v1/books { proxy_pass http://books:3000; } location /api/v1/videos { proxy_pass http://videos:3000; } location / { root /usr/share/nginx/html; index index.html index.htm; } #error_page 404 /404.html; error_page 500 502 503 504 /50x.html; location = /50x.html { root /usr/share/nginx/html; } }' > /etc/nginx/default.conf"]

  volumes {
    container_path = "/srv/www/static"
    host_path      = "${path.cwd}/web/public"
    read_only      = true
  }

  volumes = [
    "${path.cwd}/web/public:/srv/www/static",
    "${path.cwd}/default.conf:/etc/nginx/default.conf:ro",
  ]

  command = [
    "nginx",
    "-g",
    "daemon off;"
  ]
} */

resource "docker_container" "nginx" {
  image = "nginx:latest"
  name  = "nginx"

  ports {
    internal = 8080
    external = 8080
  }

  network_mode = docker_network.app_network.name

  # command = ["nginx", "-g", "daemon off;", "sudo echo 'server { listen 8080; listen [::]:80; root /srv/www/static; server_name localhost; #access_log /var/log/nginx/host.access.log main; location / { # We try to get static files from nginx first # because node is not great at IO operations try_files $uri $uri/ @web; } location @web { proxy_pass http://web:3000; } location /api/v1/search { proxy_pass http://search:3000; } location /api/v1/search/depends-on { proxy_pass http://search:3000; } location /api/v1/books { proxy_pass http://books:3000; } location /api/v1/videos { proxy_pass http://videos:3000; } location / { root /usr/share/nginx/html; index index.html index.htm; } #error_page 404 /404.html; error_page 500 502 503 504 /50x.html; location = /50x.html { root /usr/share/nginx/html; } }' > /etc/nginx/default.conf", "sudo docker exec tutorial -s reload"]

  # command = ["docker cp ${path.cwd}/default.conf tutorial:/etc/nginx/conf.d/default.conf", "docker exec tutorial nginx -s reload"]
  # must_run = true
  /*volumes = [
    "${docker_volume.nginx_static.name}/web/public:/srv/www/static",
    "${docker_volume.nginx_conf.name}/default.conf:/etc/nginx/default.conf:ro",
  ] */

  depends_on = [
    docker_container.books_service_container,
    docker_container.videos_service_container,
    docker_container.search_service_container,
    docker_container.web_service_container,
  ]
}

resource "null_resource" "copy_file" {
  depends_on = [docker_container.nginx]

  /*provisioner "local-exec" {
    command = "docker cp ${path.cwd}/default.conf ${docker_container.nginx.name}:/etc/nginx/conf.d/default.conf"
    
  } */
  provisioner "local-exec" {
    command = <<EOT
      docker cp ${path.cwd}/default.conf ${docker_container.nginx.name}:/etc/nginx/conf.d/default.conf
      docker exec ${docker_container.nginx.name} nginx -s reload
    EOT
  }

}

resource "null_resource" "web_image" {
  provisioner "local-exec" {
    command = "docker build -t fredppro/web:1.0.0 ./web"
  }

  provisioner "local-exec" {
    command = "docker login -u 'fredppro' -p 'Cloud_Computing$_2023' && docker push fredppro/web:1.0.0"
  }
}

