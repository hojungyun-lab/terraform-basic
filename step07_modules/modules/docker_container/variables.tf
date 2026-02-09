# Docker Container 모듈 - 변수 정의

variable "container_name" {
  description = "Docker 컨테이너 이름"
  type        = string
}

variable "image" {
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
}

variable "env_vars" {
  description = "환경 변수 리스트"
  type        = list(string)
  default     = []
}

variable "network_name" {
  description = "연결할 Docker 네트워크 이름 (빈 문자열이면 연결 안 함)"
  type        = string
  default     = ""
}
