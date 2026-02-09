# Step 11: 실전 프로젝트 - 루트 모듈

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
# 로컬 설정
# ─────────────────────────────────────────────
locals {
  project = var.project_name
  env     = var.environment

  common_labels = {
    project     = local.project
    environment = local.env
    managed_by  = "terraform"
  }
}

# ─────────────────────────────────────────────
# Network 모듈
# ─────────────────────────────────────────────
module "network" {
  source = "./modules/network"

  project_name = local.project
  subnet       = var.network_subnet
  gateway      = var.network_gateway
}

# ─────────────────────────────────────────────
# Frontend 모듈 (Nginx)
# ─────────────────────────────────────────────
module "frontend" {
  source = "./modules/frontend"

  project_name  = local.project
  network_name  = module.network.network_name
  external_port = var.frontend_port
  labels        = local.common_labels

  depends_on = [module.network]
}

# ─────────────────────────────────────────────
# Backend 모듈 (App + Redis)
# ─────────────────────────────────────────────
module "backend" {
  source = "./modules/backend"

  project_name   = local.project
  network_name   = module.network.network_name
  app_port       = var.backend_port
  labels         = local.common_labels

  depends_on = [module.network]
}

# ─────────────────────────────────────────────
# 헬스 체크
# ─────────────────────────────────────────────
resource "terraform_data" "health_check" {
  triggers_replace = [
    module.frontend.container_id,
    module.backend.app_container_id,
  ]

  provisioner "local-exec" {
    command = <<-EOT
      echo "==========================================="
      echo "🚀 실전 프로젝트 배포 완료!"
      echo "==========================================="
      echo ""
      echo "📋 서비스 상태:"
      echo "  Frontend (Nginx):  http://localhost:${var.frontend_port}"
      echo "  Backend  (httpd):  http://localhost:${var.backend_port}"
      echo "  Cache    (Redis):  내부 전용 (6379)"
      echo ""
      echo "🌐 네트워크: ${module.network.network_name}"
      echo "==========================================="
    EOT
  }

  depends_on = [module.frontend, module.backend]
}
