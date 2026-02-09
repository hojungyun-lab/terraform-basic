# Step 07: 모듈 실습 - 루트 모듈

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
# 공유 네트워크
# ─────────────────────────────────────────────
resource "docker_network" "app_net" {
  name = "modules-demo-network"
}

# ─────────────────────────────────────────────
# 모듈 호출: 웹 서버
# ─────────────────────────────────────────────
module "web" {
  source = "./modules/docker_container"

  container_name = "module-web"
  image          = "nginx:alpine"
  external_port  = 8090
  network_name   = docker_network.app_net.name

  env_vars = [
    "APP_NAME=web-server",
    "APP_ENV=learning"
  ]
}

# ─────────────────────────────────────────────
# 모듈 호출: API 서버
# ─────────────────────────────────────────────
module "api" {
  source = "./modules/docker_container"

  container_name = "module-api"
  image          = "httpd:alpine"
  external_port  = 8091
  network_name   = docker_network.app_net.name

  env_vars = [
    "APP_NAME=api-server",
    "APP_ENV=learning"
  ]
}
