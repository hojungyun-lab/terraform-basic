# Step 06: State 관리 실습

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
# 리소스 정의
# ─────────────────────────────────────────────

# Docker 네트워크
resource "docker_network" "app_net" {
  name = "state-demo-network"
}

# Docker 이미지
resource "docker_image" "nginx" {
  keep_locally = true
  name = "nginx:alpine"
}

# Docker 컨테이너
resource "docker_container" "web" {
  name  = "state-demo"
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = 8086
  }

  networks_advanced {
    name = docker_network.app_net.name
  }
}

# ─────────────────────────────────────────────
# 출력 값
# ─────────────────────────────────────────────
output "container_name" {
  description = "컨테이너 이름"
  value       = docker_container.web.name
}

output "container_id" {
  description = "컨테이너 ID"
  value       = docker_container.web.id
}

output "network_name" {
  description = "네트워크 이름"
  value       = docker_network.app_net.name
}

output "network_id" {
  description = "네트워크 ID"
  value       = docker_network.app_net.id
}

output "web_url" {
  description = "웹 서버 URL"
  value       = "http://localhost:8086"
}

output "state_commands" {
  description = "이 단계에서 실습할 State 명령어"
  value = <<-EOT
    terraform state list              # 리소스 목록
    terraform state show docker_container.web  # 상세 정보
    terraform state pull > backup.tfstate      # 백업
  EOT
}
