# Step 04: Variables & Outputs

## 📚 학습 목표
- 다양한 변수 타입을 정의하고 활용한다
- 변수 값을 전달하는 여러 방법을 익힌다
- 변수 유효성 검사(Validation)를 구현한다
- Output을 활용하여 결과를 체계적으로 출력한다
- 민감한 정보를 안전하게 다루는 방법을 이해한다

---

## 1. 변수 정의 (Variable Declaration)

### 기본 변수

```hcl
# 간단한 변수
variable "container_name" {
  description = "Docker 컨테이너 이름"
  type        = string
  default     = "my-app"
}
```

### 변수 속성

| 속성 | 필수 | 설명 |
|------|------|------|
| `description` | 권장 | 변수 설명 (문서화) |
| `type` | 권장 | 데이터 타입 제약 |
| `default` | 선택 | 기본값 (없으면 필수 입력) |
| `validation` | 선택 | 유효성 검사 규칙 |
| `sensitive` | 선택 | 민감 데이터 마스킹 |
| `nullable` | 선택 | null 허용 여부 |

---

## 2. 변수 타입

### 기본 타입 (Primitive)

```hcl
# String
variable "name" {
  type    = string
  default = "web-server"
}

# Number
variable "port" {
  type    = number
  default = 8080
}

# Boolean
variable "enable_ssl" {
  type    = bool
  default = false
}
```

### 복합 타입 (Collection)

```hcl
# List - 순서 있는 동일 타입 컬렉션
variable "ports" {
  type    = list(number)
  default = [80, 443, 8080]
}

# Map - 키-값 쌍
variable "tags" {
  type = map(string)
  default = {
    environment = "dev"
    team        = "backend"
  }
}

# Set - 순서 없는 고유 값
variable "allowed_ips" {
  type    = set(string)
  default = ["10.0.0.1", "10.0.0.2"]
}
```

### 구조화된 타입 (Structural)

```hcl
# Object - 명시적 구조 정의
variable "container_config" {
  type = object({
    name     = string
    image    = string
    port     = number
    replicas = number
  })
  default = {
    name     = "web"
    image    = "nginx:alpine"
    port     = 80
    replicas = 1
  }
}

# Tuple - 다양한 타입의 순서 있는 컬렉션
variable "mixed_config" {
  type    = tuple([string, number, bool])
  default = ["web", 8080, true]
}
```

---

## 3. 변수 값 전달 방법

### 우선순위 (높은 것이 우선)

```
1. -var 커맨드라인 플래그           (최우선)
2. -var-file 플래그
3. *.auto.tfvars / *.auto.tfvars.json
4. terraform.tfvars / terraform.tfvars.json
5. 환경 변수 (TF_VAR_xxx)
6. default 값
7. 대화형 프롬프트                   (최후)
```

### 방법별 예시

```bash
# 1. 커맨드라인 플래그
terraform apply -var="container_name=prod-web" -var="external_port=80"

# 2. 변수 파일 지정
terraform apply -var-file="production.tfvars"

# 3. auto.tfvars (자동 로드)
# 파일명: example.auto.tfvars
# 내용: container_name = "auto-loaded"

# 4. terraform.tfvars (자동 로드)
# 파일명: terraform.tfvars
# 내용: container_name = "default-loaded"

# 5. 환경 변수
export TF_VAR_container_name="env-web"
terraform apply
```

### tfvars 파일 형식

```hcl
# terraform.tfvars
container_name = "my-web-app"
external_port  = 8080
enable_logging = true

# 복합 타입도 지정 가능
labels = {
  environment = "production"
  team        = "platform"
}

ports = [80, 443]
```

---

## 4. 변수 유효성 검사 (Validation)

```hcl
variable "external_port" {
  description = "외부 포트 번호"
  type        = number
  default     = 8080

  validation {
    condition     = var.external_port >= 1024 && var.external_port <= 65535
    error_message = "포트 번호는 1024~65535 사이여야 합니다."
  }
}

variable "environment" {
  description = "환경 이름"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment는 dev, staging, prod 중 하나여야 합니다."
  }
}

variable "container_name" {
  description = "컨테이너 이름"
  type        = string

  validation {
    condition     = length(var.container_name) >= 3 && length(var.container_name) <= 50
    error_message = "컨테이너 이름은 3~50자 사이여야 합니다."
  }

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.container_name))
    error_message = "컨테이너 이름은 소문자로 시작하고, 소문자/숫자/하이픈만 사용 가능합니다."
  }
}
```

---

## 5. 민감한 변수 (Sensitive Variables)

```hcl
variable "db_password" {
  description = "데이터베이스 비밀번호"
  type        = string
  sensitive   = true    # plan/apply 출력에서 마스킹된다
}

# 출력에서도 sensitive 표시 필요
output "db_connection" {
  value     = "db://user:${var.db_password}@localhost"
  sensitive = true
}
```

```bash
# 민감 변수 전달 - 환경 변수 사용 (권장)
export TF_VAR_db_password="super-secret-123"
terraform apply

# 또는 -var 플래그 (이력에 남을 수 있음)
terraform apply -var="db_password=super-secret-123"
```

---

## 6. Output (출력)

### Output 정의

```hcl
# 기본 출력
output "container_id" {
  description = "생성된 컨테이너 ID"
  value       = docker_container.web.id
}

# 조건부 출력
output "web_url" {
  description = "웹 서버 URL"
  value       = var.enable_ssl ? "https://localhost:${var.external_port}" : "http://localhost:${var.external_port}"
}

# 복합 값 출력
output "container_info" {
  description = "컨테이너 종합 정보"
  value = {
    name       = docker_container.web.name
    id         = docker_container.web.id
    image      = docker_image.app.name
    ports      = var.external_port
  }
}

# 민감 정보 출력
output "connection_string" {
  value     = "sensitive-data-here"
  sensitive = true
}
```

### Output 활용

```bash
# 모든 출력 확인
terraform output

# 특정 출력 값 (스크립팅에 유용)
terraform output -raw container_id

# JSON 형태
terraform output -json

# 다른 모듈에서 참조
# module.web.container_id
```

---

## 7. Local Values (로컬 변수)

```hcl
locals {
  # 변수 조합
  full_name = "${var.project}-${var.environment}"

  # 조건부 값
  is_production = var.environment == "prod"

  # 공통 태그
  common_labels = {
    project     = var.project
    environment = var.environment
    managed_by  = "terraform"
    created_at  = timestamp()
  }

  # 계산된 값
  port_offset = var.environment == "prod" ? 0 : 1000
  actual_port = 80 + local.port_offset
}

# 사용
resource "docker_container" "web" {
  name = local.full_name
  # ...
}
```

---

## 📝 핵심 정리

1. **변수 타입**: string, number, bool, list, map, set, object, tuple
2. **변수 전달 우선순위**: `-var` > `-var-file` > `auto.tfvars` > `terraform.tfvars` > `TF_VAR_` > `default`
3. **validation** 블록으로 입력 값 검증
4. **sensitive = true**로 민감 정보 보호
5. **output**으로 결과 공유, **locals**로 내부 계산 값 관리

---

## ✅ 실습 확인

```bash
cd step04_variables

terraform init
terraform validate

# 기본값으로 실행
terraform plan
terraform apply -auto-approve

# 변수 오버라이드
terraform apply -var="container_name=custom-web" -var="external_port=9090" -auto-approve

# 출력 확인
terraform output
terraform output -json

# 정리
terraform destroy -auto-approve
```

---

## ➡️ 다음 단계

[Step 05: 데이터 소스 & 프로바이더](../step05_datasources/README.md)에서 외부 데이터를 조회하고 프로바이더를 심층 설정하는 방법을 배운다.
