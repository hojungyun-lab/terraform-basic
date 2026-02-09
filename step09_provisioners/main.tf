# Step 09: Provisioners & 외부 연동 실습

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
# Docker 이미지 & 컨테이너
# ─────────────────────────────────────────────
resource "docker_image" "nginx" {
  keep_locally = true
  name = "nginx:alpine"
}

resource "docker_container" "web" {
  name  = "provisioner-demo"
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = 8092
  }

  # 생성 후 실행: local-exec
  provisioner "local-exec" {
    command = "echo '✅ 컨테이너 [${self.name}] 생성 완료!'"
  }

  # 삭제 시 실행: local-exec
  provisioner "local-exec" {
    when    = destroy
    command = "echo '🗑️ 컨테이너 [${self.name}] 삭제 중...'"
  }
}

# ─────────────────────────────────────────────
# terraform_data: 헬스 체크 (null_resource 대체)
# ─────────────────────────────────────────────
resource "terraform_data" "health_check" {
  triggers_replace = [docker_container.web.id]

  provisioner "local-exec" {
    command = <<-EOT
      echo "🏥 헬스 체크 시작..."
      sleep 2
      HTTP_CODE=$(curl -s -o /dev/null -w "%%{http_code}" http://localhost:8092 2>/dev/null || echo "000")
      if [ "$HTTP_CODE" = "200" ]; then
        echo "✅ 서버 정상 응답 (HTTP $HTTP_CODE)"
      else
        echo "⚠️ 서버 응답: HTTP $HTTP_CODE (시작 중일 수 있음)"
      fi
    EOT
  }

  depends_on = [docker_container.web]
}

# ─────────────────────────────────────────────
# external 데이터 소스: 시스템 정보 조회
# ─────────────────────────────────────────────
data "external" "system_info" {
  program = ["bash", "${path.module}/scripts/system_info.sh"]
}

# ─────────────────────────────────────────────
# 출력
# ─────────────────────────────────────────────
output "container_name" {
  description = "컨테이너 이름"
  value       = docker_container.web.name
}

output "web_url" {
  description = "웹 서버 URL"
  value       = "http://localhost:8092"
}

output "system_info" {
  description = "시스템 정보 (external 데이터 소스)"
  value       = data.external.system_info.result
}
