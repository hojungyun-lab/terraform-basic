# Step 01: 환경 설정 확인용 Terraform 파일
# 이 파일로 Terraform + Docker Provider가 정상 작동하는지 확인한다.

terraform {
  required_version = ">= 1.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# Docker Provider 설정
provider "docker" {}

# ─────────────────────────────────────────────
# hello-world 이미지를 Pull하여 환경 확인
# ─────────────────────────────────────────────
resource "docker_image" "hello" {
  keep_locally = true
  name         = "hello-world:latest"
}

# 출력으로 설치 확인
output "image_id" {
  description = "Pull된 hello-world 이미지 ID"
  value       = docker_image.hello.image_id
}

output "setup_status" {
  description = "환경 설정 상태"
  value       = "✅ Terraform + Docker Provider 설정 완료!"
}
