# Frontend 모듈 - 리소스 (Nginx)

terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "nginx" {
  keep_locally = true
  name = "nginx:alpine"
}

resource "docker_container" "frontend" {
  name  = "${var.project_name}-frontend"
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = var.external_port
  }

  networks_advanced {
    name = var.network_name
  }

  env = [
    "NGINX_HOST=localhost",
    "NGINX_PORT=80"
  ]

  dynamic "labels" {
    for_each = var.labels
    content {
      label = labels.key
      value = labels.value
    }
  }

  labels {
    label = "component"
    value = "frontend"
  }
}
