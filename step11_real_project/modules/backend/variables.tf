# Backend 모듈 - 변수

variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "network_name" {
  description = "Docker 네트워크 이름"
  type        = string
}

variable "app_port" {
  description = "앱 서버 외부 포트"
  type        = number
  default     = 8101
}

variable "labels" {
  description = "컨테이너 라벨"
  type        = map(string)
  default     = {}
}
