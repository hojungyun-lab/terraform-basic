# Step 05: 데이터 소스 & 프로바이더 실습

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
# 데이터 소스: 기존 Docker 리소스 조회
# ─────────────────────────────────────────────

# 기본 bridge 네트워크 정보 조회
data "docker_network" "bridge" {
  name = "bridge"
}

# ─────────────────────────────────────────────
# Docker 이미지 & 컨테이너 생성
# ─────────────────────────────────────────────
resource "docker_image" "nginx" {
  keep_locally = true
  name = "nginx:alpine"
}

# 리소스에서 데이터 소스 정보를 참조
resource "docker_container" "web" {
  name  = "datasource-demo"
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = 8085
  }

  # bridge 네트워크에 연결 (데이터 소스 참조)
  networks_advanced {
    name = data.docker_network.bridge.name
  }
}

# ─────────────────────────────────────────────
# 커스텀 네트워크 생성 및 활용
# ─────────────────────────────────────────────
resource "docker_network" "custom" {
  name   = "terraform-custom-net"
  driver = "bridge"

  ipam_config {
    subnet  = "172.28.0.0/16"
    gateway = "172.28.0.1"
  }
}

resource "docker_container" "app" {
  name  = "datasource-app"
  image = docker_image.nginx.image_id

  # 커스텀 네트워크에 연결
  networks_advanced {
    name = docker_network.custom.name
  }
}
