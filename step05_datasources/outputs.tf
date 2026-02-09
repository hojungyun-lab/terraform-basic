# Step 05: 출력 값

output "bridge_network_id" {
  description = "기본 bridge 네트워크 ID (Data Source)"
  value       = data.docker_network.bridge.id
}

output "custom_network_id" {
  description = "커스텀 네트워크 ID (Resource)"
  value       = docker_network.custom.id
}

output "custom_network_subnet" {
  description = "커스텀 네트워크 서브넷"
  value       = "172.28.0.0/16"
}

output "web_container" {
  description = "웹 컨테이너 정보"
  value = {
    name    = docker_container.web.name
    network = data.docker_network.bridge.name
    url     = "http://localhost:8085"
  }
}

output "app_container" {
  description = "앱 컨테이너 정보"
  value = {
    name    = docker_container.app.name
    network = docker_network.custom.name
  }
}
