# Step 04: 변수 정의
# 다양한 변수 타입과 유효성 검사를 포함

variable "project" {
  description = "프로젝트 이름"
  type        = string
  default     = "terraform-learning"
}

variable "environment" {
  description = "환경 이름 (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment는 dev, staging, prod 중 하나여야 합니다."
  }
}

variable "container_name" {
  description = "Docker 컨테이너 이름"
  type        = string
  default     = "web"

  validation {
    condition     = length(var.container_name) >= 2 && length(var.container_name) <= 30
    error_message = "컨테이너 이름은 2~30자 사이여야 합니다."
  }
}

variable "docker_image" {
  description = "Docker 이미지 이름:태그"
  type        = string
  default     = "nginx:alpine"
}

variable "internal_port" {
  description = "컨테이너 내부 포트"
  type        = number
  default     = 80
}

variable "external_port" {
  description = "호스트 외부 포트"
  type        = number
  default     = 8084

  validation {
    condition     = var.external_port >= 1024 && var.external_port <= 65535
    error_message = "포트 번호는 1024~65535 사이여야 합니다."
  }
}
