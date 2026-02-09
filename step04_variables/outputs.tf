# Step 04: 출력 값 정의

output "container_name" {
  description = "생성된 컨테이너 이름"
  value       = docker_container.web.name
}

output "container_id" {
  description = "컨테이너 ID"
  value       = docker_container.web.id
}

output "web_url" {
  description = "웹 서버 접속 URL"
  value       = "http://localhost:${var.external_port}"
}

output "container_info" {
  description = "컨테이너 종합 정보"
  value = {
    name        = docker_container.web.name
    image       = var.docker_image
    environment = var.environment
    ports       = "${var.external_port} → ${var.internal_port}"
  }
}

output "labels" {
  description = "적용된 라벨"
  value       = local.common_labels
}
