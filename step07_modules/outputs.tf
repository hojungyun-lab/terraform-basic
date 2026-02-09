# Step 07: 루트 모듈 출력

output "web_container" {
  description = "웹 서버 컨테이너 정보"
  value = {
    name = module.web.container_name
    id   = module.web.container_id
    url  = "http://localhost:8090"
  }
}

output "api_container" {
  description = "API 서버 컨테이너 정보"
  value = {
    name = module.api.container_name
    id   = module.api.container_id
    url  = "http://localhost:8091"
  }
}

output "network_name" {
  description = "공유 네트워크 이름"
  value       = docker_network.app_net.name
}
