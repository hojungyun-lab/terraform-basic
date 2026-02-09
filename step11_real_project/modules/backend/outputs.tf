# Backend 모듈 - 출력

output "app_container_id" {
  description = "앱 서버 컨테이너 ID"
  value       = docker_container.app.id
}

output "app_container_name" {
  description = "앱 서버 컨테이너 이름"
  value       = docker_container.app.name
}

output "cache_container_id" {
  description = "캐시 서버 컨테이너 ID"
  value       = docker_container.cache.id
}

output "cache_container_name" {
  description = "캐시 서버 컨테이너 이름"
  value       = docker_container.cache.name
}
