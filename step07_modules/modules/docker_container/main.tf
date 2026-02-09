# Docker Container 모듈 - 리소스 정의

terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# Docker 이미지 Pull
resource "docker_image" "this" {
  keep_locally = true
  name = var.image
}

# Docker 컨테이너 생성
resource "docker_container" "this" {
  name  = var.container_name
  image = docker_image.this.image_id

  ports {
    internal = var.internal_port
    external = var.external_port
  }

  env = var.env_vars

  # 네트워크 연결 (network_name이 지정된 경우에만)
  dynamic "networks_advanced" {
    for_each = var.network_name != "" ? [var.network_name] : []
    content {
      name = networks_advanced.value
    }
  }
}
