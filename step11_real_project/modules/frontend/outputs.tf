# Frontend 모듈 - 출력

output "container_id" {
  description = "프론트엔드 컨테이너 ID"
  value       = docker_container.frontend.id
}

output "container_name" {
  description = "프론트엔드 컨테이너 이름"
  value       = docker_container.frontend.name
}
