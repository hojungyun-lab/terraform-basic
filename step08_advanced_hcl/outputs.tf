# Step 08: 출력 값

output "counted_containers" {
  description = "count로 생성된 컨테이너 이름 목록"
  value       = docker_container.counted[*].name
}

output "counted_urls" {
  description = "count 컨테이너 URL 목록"
  value       = [for i in range(var.container_count) : "http://localhost:${8130 + i}"]
}

output "service_containers" {
  description = "for_each로 생성된 서비스 정보"
  value = {
    for k, v in docker_container.services : k => {
      name = v.name
      id   = substr(v.id, 0, 12)
    }
  }
}

output "service_urls" {
  description = "서비스별 URL"
  value       = local.service_urls
}

output "service_names" {
  description = "서비스 이름 목록 (for 표현식)"
  value       = local.service_names
}

output "environment_config" {
  description = "환경 설정"
  value = {
    environment = var.environment
    is_prod     = local.is_prod
    log_level   = local.log_level
  }
}
