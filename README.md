# 🏗️ Terraform 초보 → 전문가 학습 로드맵

> **Terraform v1.14.x** 기준 | Docker 환경 실습 | 단계별 학습 가이드

Terraform을 처음 접하는 초보자가 전문가 수준까지 성장할 수 있도록 설계된 **13단계** 학습 콘텐츠이다. 모든 실습은 **Docker 환경**에서 진행되어 클라우드 비용 없이 학습할 수 있다.

---

## 📋 목차

| 단계 | 주제 | 난이도 | 설명 |
|:----:|------|:------:|------|
| **00** | [Terraform 개요 및 소개](./step00_overview/README.md) | ⭐ | IaC 개념, Terraform 아키텍처, 다른 도구와 비교 |
| **01** | [환경 설정](./step01_setup/README.md) | ⭐ | Terraform/Docker 설치, Docker Provider, 첫 init |
| **02** | [HCL 기초 문법](./step02_hcl_basics/README.md) | ⭐⭐ | 블록, 타입, 보간법, 리소스 참조 |
| **03** | [Terraform 기본 명령어](./step03_commands/README.md) | ⭐⭐ | init/plan/apply/destroy, fmt/validate |
| **04** | [Variables & Outputs](./step04_variables/README.md) | ⭐⭐ | 변수 타입, validation, 출력, 민감 정보 |
| **05** | [데이터 소스 & 프로바이더](./step05_datasources/README.md) | ⭐⭐⭐ | Data Source, 프로바이더 버전 관리, alias |
| **06** | [State 관리](./step06_state/README.md) | ⭐⭐⭐ | State 구조, state 명령어, import, Remote State |
| **07** | [모듈 (Modules)](./step07_modules/README.md) | ⭐⭐⭐ | 모듈 작성, 입출력, 재사용 패턴 |
| **08** | [조건문, 반복문, 동적 블록](./step08_advanced_hcl/README.md) | ⭐⭐⭐⭐ | count, for_each, for, dynamic, 내장 함수 |
| **09** | [Provisioners & 외부 연동](./step09_provisioners/README.md) | ⭐⭐⭐⭐ | local-exec, null_resource, external, templatefile |
| **10** | [워크스페이스 & 환경 분리](./step10_workspaces/README.md) | ⭐⭐⭐⭐ | Workspace, 환경별 변수 관리 |
| **11** | [실전 프로젝트](./step11_real_project/README.md) | ⭐⭐⭐⭐⭐ | Docker 멀티티어 앱 (Nginx + App + Redis) |
| **12** | [베스트 프랙티스 & 다음 단계](./step12_best_practices/README.md) | ⭐⭐⭐⭐⭐ | 코드 구조, 보안, CI/CD, 클라우드 확장 |

---

## 🚀 시작하기

### 사전 요구사항

- **Docker Desktop** 설치 및 실행 중
- **Terraform CLI** v1.0 이상 설치
- 터미널(Terminal) 기본 사용 가능
- 코드 에디터 (VS Code 권장 + HashiCorp Terraform 확장)

### 빠른 시작

```bash
# 1. 저장소 클론
git clone <repository-url>
cd terraform-basic

# 2. Terraform 설치 확인
terraform version

# 3. Docker 실행 확인
docker version

# 4. Step 00부터 학습 시작!
cd step00_overview
cat README.md
```

### Docker 실습 환경 (선택)

```bash
# Docker 컨테이너 내부에서 실습하고 싶다면:
cd step01_setup
docker compose up -d
docker exec -it terraform-lab /bin/bash

# 컨테이너 내부에서 모든 단계를 실습 가능
cd /workspace/step02_hcl_basics
terraform init
```

---

## 📖 학습 방법

### 권장 순서

```
Step 00 (개요) → Step 01 (설정) → Step 02 (HCL) → ... → Step 12 (베스트 프랙티스)
→ 순서대로 학습하는 것을 강력히 권장합니다
```

### 각 단계별 학습 흐름

```
1. README.md 읽기         ← 개념 학습
2. .tf 파일 분석           ← 코드 이해
3. terraform init         ← 초기화
4. terraform validate     ← 검증
5. terraform plan         ← 변경 사항 확인
6. terraform apply        ← 적용
7. 결과 확인               ← docker ps, curl 등
8. terraform destroy      ← 정리
```

---

## 🧪 전체 테스트

모든 단계를 순서대로 테스트:

```bash
# 각 단계별 테스트 실행
for step in step01_setup step02_hcl_basics step03_commands step04_variables \
            step05_datasources step06_state step07_modules step08_advanced_hcl \
            step09_provisioners step10_workspaces step11_real_project; do
    echo "========================================="
    echo "🧪 Testing: $step"
    echo "========================================="
    cd $step
    terraform init
    terraform validate
    terraform plan
    terraform apply -auto-approve
    terraform destroy -auto-approve
    cd ..
    echo "✅ $step 통과!"
    echo ""
done
```

---

## 📂 프로젝트 구조

```
terraform-basic/
├── README.md                              # 이 파일 (로드맵)
├── .gitignore                             # Git 제외 파일
│
├── step00_overview/                       # ⭐ 개요
│   └── README.md
│
├── step01_setup/                          # ⭐ 환경 설정
│   ├── README.md
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── main.tf
│
├── step02_hcl_basics/                     # ⭐⭐ HCL 기초
│   ├── README.md
│   ├── main.tf
│   └── outputs.tf
│
├── step03_commands/                       # ⭐⭐ 기본 명령어
│   ├── README.md
│   └── main.tf
│
├── step04_variables/                      # ⭐⭐ 변수 & 출력
│   ├── README.md
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars
│
├── step05_datasources/                    # ⭐⭐⭐ 데이터 소스
│   ├── README.md
│   ├── main.tf
│   └── outputs.tf
│
├── step06_state/                          # ⭐⭐⭐ State 관리
│   ├── README.md
│   └── main.tf
│
├── step07_modules/                        # ⭐⭐⭐ 모듈
│   ├── README.md
│   ├── main.tf
│   ├── outputs.tf
│   └── modules/docker_container/
│
├── step08_advanced_hcl/                   # ⭐⭐⭐⭐ 고급 HCL
│   ├── README.md
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
│
├── step09_provisioners/                   # ⭐⭐⭐⭐ Provisioners
│   ├── README.md
│   ├── main.tf
│   └── scripts/system_info.sh
│
├── step10_workspaces/                     # ⭐⭐⭐⭐ 워크스페이스
│   ├── README.md
│   ├── main.tf
│   └── variables.tf
│
├── step11_real_project/                   # ⭐⭐⭐⭐⭐ 실전 프로젝트
│   ├── README.md
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── modules/
│       ├── network/
│       ├── frontend/
│       └── backend/
│
└── step12_best_practices/                 # ⭐⭐⭐⭐⭐ 베스트 프랙티스
    └── README.md
```

---

## 📝 라이선스

이 학습 콘텐츠는 자유롭게 사용, 수정, 배포할 수 있다.
