# Step 10: 변수 정의

variable "docker_image" {
  description = "Docker 이미지"
  type        = string
  default     = "nginx:alpine"
}

# ─────────────────────────────────────────────
# 출력 값
# ─────────────────────────────────────────────
output "workspace" {
  description = "현재 Workspace"
  value       = terraform.workspace
}

output "container_name" {
  description = "컨테이너 이름"
  value       = docker_container.web.name
}

output "container_port" {
  description = "외부 포트"
  value       = local.current_port
}

output "web_url" {
  description = "웹 서버 URL"
  value       = "http://localhost:${local.current_port}"
}

output "environment_config" {
  description = "현재 환경 설정"
  value = {
    workspace = terraform.workspace
    log_level = local.current_config.log_level
    replicas  = local.current_config.replicas
  }
}
