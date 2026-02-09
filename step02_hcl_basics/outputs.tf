# Step 02: 출력 값 정의
# terraform output 명령어로 확인 가능

output "container_name" {
  description = "생성된 컨테이너 이름"
  value       = docker_container.web.name
}

output "container_id" {
  description = "생성된 컨테이너 ID"
  value       = docker_container.web.id
}

output "image_id" {
  description = "사용된 Docker 이미지 ID"
  value       = docker_image.nginx.image_id
}

output "web_url" {
  description = "웹 서버 접속 URL"
  value       = "http://localhost:8088"
}

output "labels" {
  description = "컨테이너에 적용된 라벨"
  value       = local.common_labels
}
