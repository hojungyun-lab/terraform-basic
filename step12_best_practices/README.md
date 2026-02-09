# Step 12: 베스트 프랙티스 & 다음 단계

## 📚 학습 목표
- Terraform 코드 구조화 패턴을 익힌다
- 네이밍 컨벤션과 코딩 스타일을 이해한다
- 보안 베스트 프랙티스를 적용한다
- CI/CD 통합 방법을 파악한다
- 클라우드 프로바이더로 확장하는 방향을 제시한다

---

## 1. 코드 구조화 패턴

### 소규모 프로젝트

```
project/
├── main.tf           # 리소스 정의
├── variables.tf      # 변수 정의
├── outputs.tf        # 출력 정의
├── versions.tf       # Terraform/프로바이더 버전
└── terraform.tfvars  # 변수 값
```

### 중규모 프로젝트

```
project/
├── main.tf           # 모듈 호출, 데이터 소스
├── variables.tf      
├── outputs.tf        
├── versions.tf       
├── terraform.tfvars  
├── locals.tf         # 로컬 변수 모음
├── data.tf           # 데이터 소스 모음
├── modules/
│   ├── networking/
│   ├── compute/
│   └── database/
└── envs/
    ├── dev.tfvars
    ├── staging.tfvars
    └── prod.tfvars
```

### 대규모 프로젝트

```
infrastructure/
├── modules/                  # 재사용 모듈 (별도 Git repo 권장)
│   ├── vpc/
│   ├── eks/
│   ├── rds/
│   └── monitoring/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── backend.tf       # Remote State 설정
│   │   └── terraform.tfvars
│   ├── staging/
│   └── prod/
└── global/                   # 환경 공통 리소스
    ├── iam/
    └── dns/
```

---

## 2. 네이밍 컨벤션

### 리소스 이름

```hcl
# ✅ Good: 명확하고 설명적인 이름
resource "docker_container" "web_server" { ... }
resource "docker_network" "application" { ... }
resource "docker_volume" "database_data" { ... }

# ❌ Bad: 모호한 이름
resource "docker_container" "c1" { ... }
resource "docker_network" "net" { ... }
```

### 변수 이름

```hcl
# ✅ Good: snake_case, 명확한 의미
variable "container_name" { ... }
variable "external_port" { ... }
variable "enable_monitoring" { ... }

# ❌ Bad
variable "cn" { ... }
variable "port1" { ... }
variable "EnableMonitoring" { ... }  # camelCase 금지
```

### 파일 이름 규칙

| 파일 | 용도 |
|------|------|
| `main.tf` | 메인 리소스 정의 |
| `variables.tf` | 입력 변수 |
| `outputs.tf` | 출력 값 |
| `versions.tf` | Terraform/프로바이더 버전 |
| `locals.tf` | 로컬 변수 |
| `data.tf` | 데이터 소스 |
| `providers.tf` | 프로바이더 설정 |
| `backend.tf` | Remote State 설정 |

---

## 3. 보안 베스트 프랙티스

### 민감 정보 관리

```hcl
# ✅ 환경 변수로 전달
# export TF_VAR_db_password="secret"

# ✅ sensitive 표시
variable "db_password" {
  type      = string
  sensitive = true
}

# ❌ 절대 하지 말 것
# variable "password" {
#   default = "hardcoded-password"  # 코드에 비밀번호 금지!
# }
```

### .gitignore 필수 항목

```gitignore
# Terraform
.terraform/
*.tfstate
*.tfstate.backup
*.tfstate.*.backup
crash.log
crash.*.log
*.tfvars        # 민감 정보 포함 가능
override.tf
override.tf.json
*_override.tf
*_override.tf.json
.terraformrc
terraform.rc
```

### State 보안

```hcl
# Remote State에 암호화 적용
terraform {
  backend "s3" {
    bucket  = "my-state-bucket"
    key     = "state/terraform.tfstate"
    region  = "ap-northeast-2"
    encrypt = true  # 서버 사이드 암호화
    
    dynamodb_table = "terraform-locks"  # State 잠금
  }
}
```

---

## 4. CI/CD 통합

### GitHub Actions 예시

```yaml
# .github/workflows/terraform.yml
name: Terraform CI/CD

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.14.4
      
      - name: Terraform Init
        run: terraform init
      
      - name: Terraform Format Check
        run: terraform fmt -check -recursive
      
      - name: Terraform Validate
        run: terraform validate
      
      - name: Terraform Plan
        run: terraform plan -out=tfplan
        
      # main 브랜치 푸시 시에만 Apply
      - name: Terraform Apply
        if: github.ref == 'refs/heads/main' && github.event_name == 'push'
        run: terraform apply -auto-approve tfplan
```

### CI/CD 파이프라인 흐름

```
PR 생성
  │
  ├── terraform fmt -check    # 코드 스타일
  ├── terraform validate      # 문법 검사
  ├── terraform plan          # 변경 사항 리뷰
  │
  ▼
PR 승인 & 병합
  │
  ├── terraform plan -out=tfplan
  └── terraform apply tfplan  # 자동 배포
```

---

## 5. 코딩 스타일 가이드

### 형식

```hcl
# ✅ 인자를 정렬 (= 기호 맞추기)
resource "docker_container" "web" {
  name  = "web-server"
  image = docker_image.nginx.image_id
  
  env = [
    "APP_ENV=production",
    "LOG_LEVEL=error",
  ]  # 마지막 요소 뒤에도 쉼표 (trailing comma)
}
```

### Terraform fmt 자동화

```bash
# Git pre-commit hook
#!/bin/bash
terraform fmt -check -recursive
if [ $? -ne 0 ]; then
  echo "❌ terraform fmt 실행 필요"
  terraform fmt -recursive
  exit 1
fi
```

---

## 6. 고급 도구 & 생태계

### 필수 도구

| 도구 | 용도 |
|------|------|
| **terraform-docs** | 자동 문서 생성 |
| **tflint** | 린터 (코드 품질 검사) |
| **tfsec** | 보안 취약점 스캔 |
| **checkov** | 정책 준수 검사 |
| **pre-commit** | Git 훅 자동화 |
| **Terragrunt** | 멀티 환경 관리 래퍼 |

### 설치 & 사용

```bash
# terraform-docs: README 자동 생성
brew install terraform-docs
terraform-docs markdown table . > DOCS.md

# tflint: 코드 품질 검사
brew install tflint
tflint --init
tflint

# tfsec: 보안 스캔
brew install tfsec
tfsec .
```

---

## 7. 다음 단계: 클라우드 확장

### AWS 프로바이더

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"  # 서울 리전
}

resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
  
  tags = {
    Name = "terraform-web"
  }
}
```

### GCP 프로바이더

```hcl
provider "google" {
  project = "my-project-id"
  region  = "asia-northeast3"  # 서울
}

resource "google_compute_instance" "web" {
  name         = "terraform-web"
  machine_type = "e2-micro"
  zone         = "asia-northeast3-a"
  # ...
}
```

### Azure 프로바이더

```hcl
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "terraform-rg"
  location = "Korea Central"
}
```

---

## 8. Terraform Cloud & Enterprise

### Terraform Cloud (무료 티어)

```hcl
terraform {
  cloud {
    organization = "my-org"
    
    workspaces {
      name = "my-app-prod"
    }
  }
}
```

| 기능 | 무료 | 유료 |
|------|------|------|
| Remote State 관리 | ✅ | ✅ |
| 원격 Plan/Apply | ✅ (제한) | ✅ |
| 팀 관리 | ❌ | ✅ |
| Sentinel 정책 | ❌ | ✅ |
| SSO | ❌ | ✅ |

---

## 9. 추천 학습 리소스

### 공식 문서
- [Terraform 공식 문서](https://developer.hashicorp.com/terraform/docs)
- [Terraform Registry](https://registry.terraform.io/) - 프로바이더 & 모듈 검색
- [Terraform Tutorials](https://developer.hashicorp.com/terraform/tutorials)

### 자격증
- **HashiCorp Certified: Terraform Associate** (입문~중급)
- 시험 범위: IaC 개념, CLI, State, 모듈, 워크플로우

### 실습 프로젝트 아이디어
1. **AWS 3-Tier 웹 앱**: VPC + ALB + EC2 + RDS
2. **Kubernetes 클러스터**: EKS/GKE on Terraform
3. **서버리스 API**: Lambda + API Gateway + DynamoDB
4. **멀티 클라우드**: AWS + GCP 하이브리드 인프라

---

## 📝 전체 학습 요약

| 단계 | 주제 | 핵심 개념 |
|------|------|-----------|
| 00 | 개요 | IaC, Terraform 아키텍처 |
| 01 | 환경 설정 | 설치, Docker Provider |
| 02 | HCL 기초 | 블록, 타입, 참조 |
| 03 | 기본 명령어 | init/plan/apply/destroy |
| 04 | Variables | 변수 타입, validation, outputs |
| 05 | 데이터 소스 | data, 프로바이더 버전 |
| 06 | State | 상태 관리, import |
| 07 | 모듈 | 재사용, 캡슐화 |
| 08 | 고급 HCL | count, for_each, dynamic |
| 09 | Provisioners | local-exec, external |
| 10 | 워크스페이스 | 환경 분리 |
| 11 | 실전 프로젝트 | 멀티티어 아키텍처 |
| 12 | 베스트 프랙티스 | 보안, CI/CD, 클라우드 |

---

## 🎉 축하합니다!

이 가이드를 모두 완료했다면, Terraform의 핵심 개념부터 실전 활용까지 체계적으로 학습한 것이다.

다음 단계로 **클라우드 프로바이더**(AWS/GCP/Azure)를 추가하여 실제 인프라를 관리해 보자!
