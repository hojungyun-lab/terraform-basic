# Network 모듈 - 출력

output "network_name" {
  description = "생성된 네트워크 이름"
  value       = docker_network.app.name
}

output "network_id" {
  description = "네트워크 ID"
  value       = docker_network.app.id
}
