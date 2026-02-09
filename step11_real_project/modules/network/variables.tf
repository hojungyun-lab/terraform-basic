# Network 모듈 - 변수

variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "subnet" {
  description = "네트워크 서브넷"
  type        = string
  default     = "172.30.0.0/16"
}

variable "gateway" {
  description = "네트워크 게이트웨이"
  type        = string
  default     = "172.30.0.1"
}
