# Step 07: 모듈 (Modules)

## 📚 학습 목표
- 모듈의 개념과 필요성을 이해한다
- 로컬 모듈을 직접 작성한다
- 모듈 입력(Variables)과 출력(Outputs)을 활용한다
- 모듈을 호출하고 재사용한다

---

## 1. 모듈이란?

### 개념

**모듈**은 함께 사용되는 Terraform 리소스의 **재사용 가능한 패키지**이다.

```
모듈 = 함수와 비슷한 개념
├── 입력 (Variables)  → 함수의 매개변수
├── 리소스 정의       → 함수의 본문
└── 출력 (Outputs)    → 함수의 반환값
```

### 왜 모듈을 사용하는가?

| 이유 | 설명 |
|------|------|
| **재사용** | 동일한 인프라 패턴을 여러 곳에서 사용 |
| **캡슐화** | 복잡한 리소스를 추상화 |
| **일관성** | 팀 표준 패턴 강제 |
| **유지보수** | 변경 시 모듈만 수정하면 전체 적용 |

### 모듈 종류

```
모듈 종류
├── Root Module (루트 모듈)     → 메인 디렉토리의 .tf 파일들
├── Child Module (자식 모듈)    → module 블록으로 호출하는 모듈
├── Local Module (로컬 모듈)    → 프로젝트 내 디렉토리에 위치
└── Remote Module (원격 모듈)   → Registry, Git, S3 등에서 가져옴
```

---

## 2. 모듈 구조

### 표준 디렉토리 구조

```
modules/
└── docker_container/
    ├── main.tf          # 리소스 정의
    ├── variables.tf     # 입력 변수
    └── outputs.tf       # 출력 값
```

### 모듈 작성 규칙

1. **최소한의 파일**: `main.tf`, `variables.tf`, `outputs.tf`
2. **모든 입력 변수에 description 필수**
3. **type과 default 지정 권장**
4. **출력으로 필요한 정보 노출**

---

## 3. 로컬 모듈 작성

### modules/docker_container/variables.tf

```hcl
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
  description = "연결할 Docker 네트워크 이름 (선택)"
  type        = string
  default     = ""
}
```

### modules/docker_container/main.tf

```hcl
resource "docker_image" "this" {
  name = var.image
}

resource "docker_container" "this" {
  name  = var.container_name
  image = docker_image.this.image_id

  ports {
    internal = var.internal_port
    external = var.external_port
  }

  env = var.env_vars

  dynamic "networks_advanced" {
    for_each = var.network_name != "" ? [var.network_name] : []
    content {
      name = networks_advanced.value
    }
  }
}
```

### modules/docker_container/outputs.tf

```hcl
output "container_id" {
  description = "생성된 컨테이너 ID"
  value       = docker_container.this.id
}

output "container_name" {
  description = "컨테이너 이름"
  value       = docker_container.this.name
}

output "image_id" {
  description = "사용된 이미지 ID"
  value       = docker_image.this.image_id
}
```

---

## 4. 모듈 호출

### 기본 호출

```hcl
# 로컬 모듈 호출
module "web" {
  source = "./modules/docker_container"

  container_name = "module-web"
  external_port  = 8090
}

# 모듈 출력 참조
output "web_id" {
  value = module.web.container_id
}
```

### 여러 인스턴스

```hcl
# 같은 모듈을 여러 번 호출
module "web" {
  source = "./modules/docker_container"

  container_name = "module-web"
  external_port  = 8090
}

module "api" {
  source = "./modules/docker_container"

  container_name = "module-api"
  image          = "httpd:alpine"
  external_port  = 8091
}
```

### 원격 모듈 (참고)

```hcl
# Terraform Registry
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"
  # ...
}

# Git 저장소
module "custom" {
  source = "git::https://github.com/user/repo.git//modules/mymodule?ref=v1.0"
}
```

---

## 5. 모듈 모범 사례

### ✅ 권장 사항

```hcl
# 1. 항상 버전 고정 (원격 모듈)
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"  # 반드시 고정!
}

# 2. 설명이 잘 된 변수
variable "instance_type" {
  description = "EC2 인스턴스 타입 (예: t3.micro)"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = contains(["t3.micro", "t3.small", "t3.medium"], var.instance_type)
    error_message = "허용된 인스턴스 타입: t3.micro, t3.small, t3.medium"
  }
}

# 3. 필요한 출력만 노출
output "container_id" {
  description = "컨테이너 ID"
  value       = docker_container.this.id
}
```

### ❌ 피해야 할 사항

```hcl
# 하드코딩된 값
resource "docker_container" "web" {
  name = "hardcoded-name"  # ❌ 변수로!
}

# 설명 없는 변수
variable "x" {  # ❌ 의미 있는 이름 + description
  default = 80
}
```

---

## 📝 핵심 정리

1. **모듈**은 재사용 가능한 Terraform 리소스 패키지
2. 표준 구조: `main.tf` + `variables.tf` + `outputs.tf`
3. `source`로 로컬/원격 모듈 경로 지정
4. `module.이름.출력`으로 모듈 출력 값 참조
5. 원격 모듈은 반드시 **version** 고정

---

## ✅ 실습 확인

```bash
cd step07_modules

terraform init
terraform validate
terraform plan
terraform apply -auto-approve

# 모듈 결과 확인
terraform output
docker ps | grep module-

# 정리
terraform destroy -auto-approve
```

---

## ➡️ 다음 단계

[Step 08: 조건문, 반복문, 동적 블록](../step08_advanced_hcl/README.md)에서 HCL의 고급 표현식을 학습한다.
