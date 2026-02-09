# Step 04: 변수 값 파일
# terraform apply 시 자동으로 로드된다

project        = "terraform-learning"
environment    = "dev"
container_name = "variables-demo"
docker_image   = "nginx:alpine"
internal_port  = 80
external_port  = 8084
