# Step 03: Terraform 기본 명령어 실습
# 전체 라이프사이클을 연습하기 위한 설정 파일

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
# 변수 정의
# ─────────────────────────────────────────────
variable "container_name" {
  description = "컨테이너 이름"
  type        = string
  default     = "commands-demo"
}

variable "external_port" {
  description = "외부 포트"
  type        = number
  default     = 8089
}

# ─────────────────────────────────────────────
# 리소스 정의
# ─────────────────────────────────────────────
resource "docker_image" "nginx" {
  keep_locally = true
  name         = "nginx:alpine"
}

resource "docker_container" "web" {
  name  = var.container_name
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = var.external_port
  }

  # 컨테이너 재시작 정책
  restart = "unless-stopped"
}

# ─────────────────────────────────────────────
# 출력 정의
# ─────────────────────────────────────────────
output "container_name" {
  description = "컨테이너 이름"
  value       = docker_container.web.name
}

output "container_id" {
  description = "컨테이너 ID (짧은 형태)"
  value       = substr(docker_container.web.id, 0, 12)
}

output "web_url" {
  description = "웹 서버 URL"
  value       = "http://localhost:${var.external_port}"
}

output "image_name" {
  description = "사용된 이미지 이름"
  value       = docker_image.nginx.name
}
