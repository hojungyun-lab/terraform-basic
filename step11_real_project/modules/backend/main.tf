# Backend 모듈 - 리소스 (App + Redis)

terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# ─────────────────────────────────────────────
# Application Server (httpd)
# ─────────────────────────────────────────────
resource "docker_image" "app" {
  keep_locally = true
  name = "httpd:alpine"
}

resource "docker_container" "app" {
  name  = "${var.project_name}-backend-app"
  image = docker_image.app.image_id

  ports {
    internal = 80
    external = var.app_port
  }

  networks_advanced {
    name = var.network_name
  }

  env = [
    "APP_NAME=${var.project_name}",
    "REDIS_HOST=${var.project_name}-backend-cache",
    "REDIS_PORT=6379"
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
    value = "backend-app"
  }

  depends_on = [docker_container.cache]
}

# ─────────────────────────────────────────────
# Cache Server (Redis)
# ─────────────────────────────────────────────
resource "docker_image" "redis" {
  keep_locally = true
  name = "redis:alpine"
}

resource "docker_container" "cache" {
  name  = "${var.project_name}-backend-cache"
  image = docker_image.redis.image_id

  networks_advanced {
    name = var.network_name
  }

  dynamic "labels" {
    for_each = var.labels
    content {
      label = labels.key
      value = labels.value
    }
  }

  labels {
    label = "component"
    value = "backend-cache"
  }
}
