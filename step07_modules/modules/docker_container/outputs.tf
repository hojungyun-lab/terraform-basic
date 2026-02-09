# Docker Container 모듈 - 출력 정의

output "container_id" {
  description = "생성된 컨테이너 ID"
  value       = docker_container.this.id
}

output "container_name" {
  description = "컨테이너 이름"
  value       = docker_container.this.name
}

output "image_id" {
  description = "사용된 이미지 ID"
  value       = docker_image.this.image_id
}
