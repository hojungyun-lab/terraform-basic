# Step 02: HCL 기초 문법 - 실습 파일
# Docker 이미지를 Pull하고 Nginx 컨테이너를 생성한다

# ─────────────────────────────────────────────
# Terraform & Provider 설정
# ─────────────────────────────────────────────
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
# 로컬 변수 (locals)
# ─────────────────────────────────────────────
locals {
  project        = "hcl-basics"
  environment    = "learning"
  container_name = "${local.project}-nginx"

  # Map 타입 로컬 변수
  common_labels = {
    project     = local.project
    environment = local.environment
    managed_by  = "terraform"
  }
}

# ─────────────────────────────────────────────
# 리소스 정의
# ─────────────────────────────────────────────

# 1. Docker 이미지 Pull
resource "docker_image" "nginx" {
  keep_locally = true
  name         = "nginx:alpine"
}

# 2. Docker 컨테이너 생성
#    - docker_image.nginx를 참조하여 의존성 자동 설정
resource "docker_container" "web" {
  name  = local.container_name
  image = docker_image.nginx.image_id

  # 중첩 블록: 포트 매핑
  ports {
    internal = 80
    external = 8088
  }

  # 리스트 타입: 환경 변수
  env = [
    "NGINX_HOST=localhost",
    "NGINX_PORT=80"
  ]

  # Map 참조: 라벨
  labels {
    label = "project"
    value = local.common_labels["project"]
  }

  labels {
    label = "environment"
    value = local.common_labels["environment"]
  }

  labels {
    label = "managed_by"
    value = local.common_labels["managed_by"]
  }
}
