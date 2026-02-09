# Step 10: 워크스페이스 & 환경 분리

## 📚 학습 목표
- Terraform Workspace 개념을 이해한다
- Workspace 명령어를 마스터한다
- 환경별(dev/staging/prod) 변수를 관리한다
- `terraform.workspace`로 동적 설정을 구현한다

---

## 1. Workspace란?

### 개념

**Workspace**는 동일한 Terraform 코드로 **여러 환경**을 관리하기 위한 메커니즘이다.

```
동일한 .tf 코드
    │
    ├── default workspace  → terraform.tfstate (기본)
    ├── dev workspace      → terraform.tfstate.d/dev/terraform.tfstate
    ├── staging workspace  → terraform.tfstate.d/staging/terraform.tfstate
    └── prod workspace     → terraform.tfstate.d/prod/terraform.tfstate
```

### Workspace vs 디렉토리 분리

| 방식 | 장점 | 단점 |
|------|------|------|
| **Workspace** | 코드 중복 없음, 간편 | 동일 코드 강제 |
| **디렉토리 분리** | 환경별 코드 자유 | 코드 중복 가능 |
| **Terragrunt** | 유연한 환경 관리 | 추가 도구 필요 |

> 💡 **실무 권장**: 소규모 프로젝트는 Workspace, 대규모 프로젝트는 디렉토리 분리 또는 Terragrunt 사용

---

## 2. Workspace 명령어

### 기본 명령어

```bash
# 현재 Workspace 확인
terraform workspace show
# default

# Workspace 목록
terraform workspace list
# * default

# 새 Workspace 생성 및 전환
terraform workspace new dev
# Created and switched to workspace "dev"!

terraform workspace new staging
terraform workspace new prod

# Workspace 전환
terraform workspace select dev

# Workspace 삭제
terraform workspace delete staging
# ⚠️ 리소스가 남아있으면 삭제 불가
```

### Workspace 목록 확인

```bash
terraform workspace list
#   default
# * dev       ← 현재 Workspace
#   staging
#   prod
```

---

## 3. terraform.workspace 활용

### 환경별 동적 설정

```hcl
# terraform.workspace 내장 변수로 현재 Workspace를 참조
locals {
  # 환경별 이름 접두사
  name_prefix = "ws-${terraform.workspace}"

  # 환경별 포트
  port_map = {
    default = 8093
    dev     = 8094
    staging = 8095
    prod    = 8096
  }

  # 환경별 설정
  config = {
    default = { replicas = 1, log_level = "debug" }
    dev     = { replicas = 1, log_level = "debug" }
    staging = { replicas = 2, log_level = "info" }
    prod    = { replicas = 3, log_level = "error" }
  }

  current_port   = lookup(local.port_map, terraform.workspace, 8093)
  current_config = lookup(local.config, terraform.workspace, local.config["default"])
}

resource "docker_container" "web" {
  name  = "${local.name_prefix}-web"
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = local.current_port
  }

  env = [
    "ENV=${terraform.workspace}",
    "LOG_LEVEL=${local.current_config.log_level}"
  ]
}
```

---

## 4. 환경별 변수 파일 관리

### 파일 구조

```
step10_workspaces/
├── main.tf
├── variables.tf
├── envs/
│   ├── dev.tfvars
│   ├── staging.tfvars
│   └── prod.tfvars
```

### 환경별 tfvars

```hcl
# envs/dev.tfvars
container_count = 1
log_level       = "debug"
```

```hcl
# envs/prod.tfvars
container_count = 3
log_level       = "error"
```

### 환경별 적용

```bash
# dev 환경
terraform workspace select dev
terraform apply -var-file="envs/dev.tfvars"

# prod 환경
terraform workspace select prod
terraform apply -var-file="envs/prod.tfvars"
```

---

## 5. Workspace 패턴

### 패턴 1: lookup 함수

```hcl
locals {
  instance_type = lookup({
    dev     = "t3.micro"
    staging = "t3.small"
    prod    = "t3.large"
  }, terraform.workspace, "t3.micro")
}
```

### 패턴 2: 조건문

```hcl
locals {
  is_prod = terraform.workspace == "prod"

  container_count = local.is_prod ? 3 : 1
  enable_logging  = local.is_prod ? true : false
}
```

---

## ⚠️ Workspace 주의사항

1. **default Workspace를 프로덕션에 사용하지 마라**
2. **Workspace 이름은 리소스 이름에 포함**시켜 충돌 방지
3. **Remote State 사용 시** Workspace별로 자동 분리됨
4. **CI/CD에서** 환경 변수로 Workspace를 지정

```bash
# CI/CD 예시
export TF_WORKSPACE=prod
terraform apply -auto-approve
```

---

## 📝 핵심 정리

1. **Workspace**는 같은 코드로 여러 환경을 관리하는 방법
2. `terraform.workspace`로 현재 환경 이름을 참조
3. `lookup` 함수로 환경별 설정 값을 동적으로 결정
4. 환경별 `.tfvars` 파일로 변수 관리
5. 리소스 이름에 Workspace를 포함하여 **충돌 방지**

---

## ✅ 실습 확인

```bash
cd step10_workspaces

terraform init

# default에서 실행
terraform validate
terraform apply -auto-approve
terraform output

# dev workspace 생성 및 전환
terraform workspace new dev
terraform apply -auto-approve
terraform output

# 두 환경의 리소스 확인
docker ps | grep ws-

# 정리 (각 workspace에서)
terraform destroy -auto-approve
terraform workspace select default
terraform destroy -auto-approve

# workspace 삭제
terraform workspace delete dev
```

---

## ➡️ 다음 단계

[Step 11: 실전 프로젝트](../step11_real_project/README.md)에서 Docker 기반 멀티티어 애플리케이션을 구축한다.
