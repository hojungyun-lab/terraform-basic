# Step 11: 변수 정의

variable "project_name" {
  description = "프로젝트 이름"
  type        = string
  default     = "real-project"
}

variable "environment" {
  description = "환경 (dev/staging/prod)"
  type        = string
  default     = "dev"
}

variable "network_subnet" {
  description = "Docker 네트워크 서브넷"
  type        = string
  default     = "172.30.0.0/16"
}

variable "network_gateway" {
  description = "Docker 네트워크 게이트웨이"
  type        = string
  default     = "172.30.0.1"
}

variable "frontend_port" {
  description = "프론트엔드 외부 포트"
  type        = number
  default     = 8100
}

variable "backend_port" {
  description = "백엔드 외부 포트"
  type        = number
  default     = 8101
}
