# Network 모듈 - 리소스

terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_network" "app" {
  name   = "${var.project_name}-network"
  driver = "bridge"

  ipam_config {
    subnet  = var.subnet
    gateway = var.gateway
  }
}
