# Step 10: 워크스페이스 & 환경 분리 실습

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
# 환경별 설정 (terraform.workspace 활용)
# ─────────────────────────────────────────────
locals {
  name_prefix = "ws-${terraform.workspace}"

  # 환경별 포트 매핑
  port_map = {
    default = 8093
    dev     = 8094
    staging = 8095
    prod    = 8096
  }

  # 환경별 설정
  env_config = {
    default = { log_level = "debug", replicas = 1 }
    dev     = { log_level = "debug", replicas = 1 }
    staging = { log_level = "info", replicas = 2 }
    prod    = { log_level = "error", replicas = 3 }
  }

  current_port   = lookup(local.port_map, terraform.workspace, 8093)
  current_config = lookup(local.env_config, terraform.workspace, local.env_config["default"])
}

# ─────────────────────────────────────────────
# Docker 이미지
# ─────────────────────────────────────────────
resource "docker_image" "nginx" {
  keep_locally = true
  name         = var.docker_image
}

# ─────────────────────────────────────────────
# Docker 컨테이너 (workspace별로 다른 이름/포트)
# ─────────────────────────────────────────────
resource "docker_container" "web" {
  name  = "${local.name_prefix}-web"
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = local.current_port
  }

  env = [
    "APP_ENV=${terraform.workspace}",
    "LOG_LEVEL=${local.current_config.log_level}"
  ]

  labels {
    label = "workspace"
    value = terraform.workspace
  }

  labels {
    label = "managed_by"
    value = "terraform"
  }
}
