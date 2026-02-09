# Step 04: Variables & Outputs 실습
# 다양한 변수 타입과 출력을 활용하는 Docker 설정

terraform {
  required_version = ">= 1.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

# ─────────────────────────────────────────────
# 로컬 값
# ─────────────────────────────────────────────
locals {
  full_name = "${var.project}-${var.environment}-${var.container_name}"

  common_labels = {
    project     = var.project
    environment = var.environment
    managed_by  = "terraform"
  }
}

# ─────────────────────────────────────────────
# 리소스 정의
# ─────────────────────────────────────────────
resource "docker_image" "app" {
  keep_locally = true
  name         = var.docker_image
}

resource "docker_container" "web" {
  name  = local.full_name
  image = docker_image.app.image_id

  ports {
    internal = var.internal_port
    external = var.external_port
  }

  env = [
    "APP_ENV=${var.environment}",
    "APP_PORT=${var.internal_port}"
  ]

  dynamic "labels" {
    for_each = local.common_labels
    content {
      label = labels.key
      value = labels.value
    }
  }
}
