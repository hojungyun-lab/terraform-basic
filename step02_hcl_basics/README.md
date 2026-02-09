# Step 02: HCL 기초 문법

## 📚 학습 목표
- HCL(HashiCorp Configuration Language)의 기본 구조를 이해한다
- 블록, 인자, 표현식 개념을 학습한다
- 주요 데이터 타입을 활용한다
- Docker 리소스를 코드로 정의한다

---

## 1. HCL 기본 구조

### 블록(Block) 구조

HCL의 모든 설정은 **블록** 단위로 구성된다.

```hcl
# 블록 기본 형태
블록타입 "라벨1" "라벨2" {
  인자명 = 값
  
  중첩블록 {
    인자명 = 값
  }
}
```

### 주요 블록 타입

| 블록 | 라벨 | 용도 |
|------|------|------|
| `terraform` | 없음 | Terraform 자체 설정 |
| `provider` | 프로바이더명 | 프로바이더 설정 |
| `resource` | 타입, 이름 | 리소스 생성/관리 |
| `data` | 타입, 이름 | 외부 데이터 조회 |
| `variable` | 이름 | 입력 변수 정의 |
| `output` | 이름 | 출력 값 정의 |
| `locals` | 없음 | 로컬 변수 정의 |
| `module` | 이름 | 모듈 호출 |

```hcl
# terraform 블록 - 라벨 없음
terraform {
  required_version = ">= 1.0"
}

# provider 블록 - 라벨 1개 (프로바이더명)
provider "docker" {}

# resource 블록 - 라벨 2개 (타입, 이름)
resource "docker_image" "nginx" {
  name = "nginx:latest"
}

# variable 블록 - 라벨 1개 (변수명)
variable "container_name" {
  default = "my-container"
}

# output 블록 - 라벨 1개 (출력명)
output "image_id" {
  value = docker_image.nginx.image_id
}
```

---

## 2. 데이터 타입

### 기본 타입 (Primitive Types)

```hcl
# 문자열 (String)
name = "hello-terraform"

# 숫자 (Number) 
port = 8080

# 불리언 (Boolean)
enabled = true
```

### 복합 타입 (Complex Types)

```hcl
# 리스트 (List) - 순서가 있는 동일 타입 값의 모음
ports = [80, 443, 8080]
names = ["web", "api", "db"]

# 맵 (Map) - 키-값 쌍
tags = {
  environment = "dev"
  team        = "backend"
  project     = "learning"
}

# 셋 (Set) - 순서 없는 고유 값의 모음
allowed_cidrs = toset(["10.0.0.0/8", "172.16.0.0/12"])

# 오브젝트 (Object) - 다양한 타입의 키-값
config = {
  name    = "web"      # string
  port    = 80         # number
  enabled = true       # bool
}

# 튜플 (Tuple) - 다양한 타입의 순서 있는 모음
mixed = ["hello", 42, true]
```

---

## 3. 문자열 보간법 (String Interpolation)

```hcl
# 변수 참조
variable "project" {
  default = "terraform-learning"
}

variable "environment" {
  default = "dev"
}

# 보간법으로 문자열 조합
resource "docker_container" "web" {
  name = "${var.project}-${var.environment}"
  # 결과: "terraform-learning-dev"
  
  image = docker_image.nginx.image_id
}

# 여러 줄 문자열 (Heredoc)
locals {
  config = <<-EOT
    server {
      listen 80;
      server_name ${var.project}.local;
    }
  EOT
}
```

---

## 4. 주석 (Comments)

```hcl
# 한 줄 주석 (해시)

// 한 줄 주석 (슬래시) - C 스타일

/* 
   여러 줄 주석
   블록 코멘트
*/
```

---

## 5. 리소스 참조 (References)

```hcl
# 리소스 간 참조
# 형식: 리소스타입.리소스이름.속성

resource "docker_image" "nginx" {
  name = "nginx:latest"
}

resource "docker_container" "web" {
  name  = "web-server"
  image = docker_image.nginx.image_id  # ← 다른 리소스 참조
  
  ports {
    internal = 80
    external = 8080
  }
}

# Terraform은 참조를 분석하여 자동으로 의존성 순서를 결정한다
# 위 예시에서는 이미지를 먼저 Pull한 후 컨테이너를 생성한다
```

### 참조 타입

| 참조 대상 | 문법 | 예시 |
|-----------|------|------|
| 리소스 | `TYPE.NAME.ATTR` | `docker_image.nginx.image_id` |
| 변수 | `var.NAME` | `var.container_name` |
| 로컬값 | `local.NAME` | `local.common_tags` |
| 데이터소스 | `data.TYPE.NAME.ATTR` | `data.docker_image.latest.id` |
| 모듈 출력 | `module.NAME.OUTPUT` | `module.web.container_id` |

---

## 6. 중첩 블록 (Nested Blocks)

```hcl
resource "docker_container" "web" {
  name  = "web-server"
  image = docker_image.nginx.image_id

  # 중첩 블록 - ports
  ports {
    internal = 80
    external = 8080
  }

  # 여러 개의 중첩 블록 사용 가능
  ports {
    internal = 443
    external = 8443
  }

  # 중첩 블록 - env (환경 변수)
  env = [
    "NGINX_HOST=localhost",
    "NGINX_PORT=80"
  ]

  # 중첩 블록 - volumes
  volumes {
    host_path      = "/tmp/nginx"
    container_path = "/usr/share/nginx/html"
  }
}
```

---

## 7. 실습 파일 설명

이 단계에 포함된 `main.tf`는 다음을 실습한다:

1. **Terraform/Provider 블록** 선언
2. **Docker 이미지** 리소스 정의
3. **Docker 컨테이너** 리소스 (포트 매핑 포함)
4. **리소스 참조** (이미지 → 컨테이너)
5. **Output** 으로 결과 확인

---

## 📝 핵심 정리

1. HCL은 **블록** 기반 구조: `블록타입 "라벨" { ... }`
2. 기본 타입: **string, number, bool** / 복합 타입: **list, map, set, object, tuple**
3. `${}` 보간법으로 변수와 리소스 참조를 문자열에 삽입
4. 리소스 참조 형식: `리소스타입.이름.속성`
5. Terraform이 참조를 분석하여 **의존성 순서를 자동 결정**

---

## ✅ 실습 확인

```bash
cd step02_hcl_basics

terraform init
terraform validate
terraform plan
terraform apply -auto-approve

# 컨테이너 확인
docker ps | grep hcl-basics

# 웹 서버 접속 테스트
curl http://localhost:8088

# 출력 값 확인
terraform output

# 정리
terraform destroy -auto-approve
```

---

## ➡️ 다음 단계

[Step 03: Terraform 기본 명령어](../step03_commands/README.md)에서 Terraform CLI 명령어를 심층 학습한다.
