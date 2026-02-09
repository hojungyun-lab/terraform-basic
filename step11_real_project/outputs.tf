# Step 11: 출력 정의

output "project_name" {
  description = "프로젝트 이름"
  value       = var.project_name
}

output "network" {
  description = "네트워크 정보"
  value = {
    name    = module.network.network_name
    id      = module.network.network_id
    subnet  = var.network_subnet
  }
}

output "frontend" {
  description = "프론트엔드 정보"
  value = {
    name = module.frontend.container_name
    url  = "http://localhost:${var.frontend_port}"
  }
}

output "backend" {
  description = "백엔드 정보"
  value = {
    app_name   = module.backend.app_container_name
    app_url    = "http://localhost:${var.backend_port}"
    cache_name = module.backend.cache_container_name
  }
}

output "all_urls" {
  description = "모든 서비스 URL"
  value = {
    frontend = "http://localhost:${var.frontend_port}"
    backend  = "http://localhost:${var.backend_port}"
  }
}
