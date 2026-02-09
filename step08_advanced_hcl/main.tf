# Step 08: 조건문, 반복문, 동적 블록 실습

terraform {
  required_version = ">= 1.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

# ─────────────────────────────────────────────
# 변수 정의
# ─────────────────────────────────────────────
variable "environment" {
  description = "환경 (dev/staging/prod)"
  type        = string
  default     = "dev"
}

variable "container_count" {
  description = "count 방식으로 생성할 컨테이너 수"
  type        = number
  default     = 2
}

variable "services" {
  description = "for_each 방식으로 생성할 서비스 정의"
  type = map(object({
    image = string
    port  = number
  }))
  default = {
    web = {
      image = "nginx:alpine"
      port  = 8120
    }
    api = {
      image = "httpd:alpine"
      port  = 8121
    }
  }
}

variable "labels" {
  description = "동적 라벨"
  type        = map(string)
  default = {
    project     = "terraform-learning"
    environment = "dev"
    managed_by  = "terraform"
    step        = "08-advanced-hcl"
  }
}

# ─────────────────────────────────────────────
# 로컬 변수 (조건문 & for 표현식)
# ─────────────────────────────────────────────
locals {
  is_prod = var.environment == "prod"

  # 조건 표현식
  log_level = local.is_prod ? "error" : "debug"

  # for 표현식: 서비스명 리스트
  service_names = [for k, v in var.services : k]

  # for 표현식: URL 맵 생성
  service_urls = { for k, v in var.services : k => "http://localhost:${v.port}" }
}

# ─────────────────────────────────────────────
# count 기반 리소스 생성
# ─────────────────────────────────────────────
resource "docker_image" "nginx" {
  keep_locally = true
  name = "nginx:alpine"
}

resource "docker_container" "counted" {
  count = var.container_count

  name  = "advanced-count-${count.index}"
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = 8130 + count.index
  }

  env = [
    "INSTANCE_INDEX=${count.index}",
    "LOG_LEVEL=${local.log_level}"
  ]
}

# ─────────────────────────────────────────────
# for_each 기반 리소스 생성
# ─────────────────────────────────────────────
resource "docker_image" "service_images" {
  for_each = var.services
  name     = each.value.image
}

resource "docker_container" "services" {
  for_each = var.services

  name  = "advanced-${each.key}"
  image = docker_image.service_images[each.key].image_id

  ports {
    internal = 80
    external = each.value.port
  }

  # dynamic 블록: 라벨 동적 생성
  dynamic "labels" {
    for_each = var.labels
    content {
      label = labels.key
      value = labels.value
    }
  }

  env = [
    "SERVICE_NAME=${each.key}",
    "LOG_LEVEL=${local.log_level}"
  ]
}
