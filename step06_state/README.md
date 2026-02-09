# Step 06: State 관리

## 📚 학습 목표
- Terraform State의 역할과 구조를 이해한다
- `terraform state` 명령어를 마스터한다
- State 파일의 백업 및 복구 방법을 학습한다
- Remote State 개념을 이해한다
- State 이관(Migration)을 실습한다

---

## 1. State란?

### 개념

**State 파일** (`terraform.tfstate`)은 Terraform이 관리하는 인프라의 **현재 상태**를 기록한다.

```
┌──────────────────┐     비교     ┌──────────────────┐
│   .tf 파일        │ ◄──────────► │  terraform.tfstate │
│  (원하는 상태)     │              │  (현재 상태)        │
└──────────────────┘              └──────────────────┘
         │                                 │
         │          차이점 계산              │
         └─────────► Plan ◄────────────────┘
                      │
                      ▼
               인프라에 적용 (Apply)
```

### State가 필요한 이유

| 이유 | 설명 |
|------|------|
| **매핑** | 코드 리소스 ↔ 실제 인프라의 매핑 |
| **성능** | 매번 API 호출 대신 State로 빠르게 비교 |
| **메타데이터** | 의존성, 프로바이더 정보 저장 |
| **변경 감지** | 이전 상태와 비교하여 변경 사항 결정 |

---

## 2. State 파일 구조

```json
{
  "version": 4,
  "terraform_version": "1.14.4",
  "serial": 3,
  "lineage": "unique-id-here",
  "outputs": {
    "container_name": {
      "value": "state-demo",
      "type": "string"
    }
  },
  "resources": [
    {
      "mode": "managed",
      "type": "docker_container",
      "name": "web",
      "provider": "provider[\"registry.terraform.io/kreuzwerker/docker\"]",
      "instances": [
        {
          "attributes": {
            "id": "abc123...",
            "name": "state-demo",
            "image": "sha256:..."
          }
        }
      ]
    }
  ]
}
```

### 주요 필드

| 필드 | 설명 |
|------|------|
| `version` | State 형식 버전 |
| `serial` | 변경될 때마다 증가하는 시리얼 번호 |
| `lineage` | State의 고유 ID |
| `outputs` | 출력 값 |
| `resources` | 관리 중인 리소스 목록과 속성 |

---

## 3. terraform state 명령어

### 리소스 목록 확인

```bash
# 관리 중인 모든 리소스 나열
terraform state list

# 출력 예시:
# docker_container.web
# docker_image.nginx
# docker_network.app_net
```

### 리소스 상세 정보

```bash
# 특정 리소스의 전체 속성 확인
terraform state show docker_container.web

# 출력 예시:
# resource "docker_container" "web" {
#     id       = "abc123..."
#     name     = "state-demo"
#     image    = "sha256:..."
#     ports {
#         internal = 80
#         external = 8086
#     }
# }
```

### 리소스 이름 변경 (mv)

```bash
# 코드에서 리소스 이름을 변경한 경우
# State도 일치시켜야 한다
terraform state mv docker_container.old_name docker_container.new_name

# 모듈로 이동
terraform state mv docker_container.web module.web.docker_container.main
```

### State에서 리소스 제거 (rm)

```bash
# State에서 제거 (실제 인프라는 유지)
# → Terraform이 더 이상 이 리소스를 관리하지 않음
terraform state rm docker_container.web

# 사용 사례:
# - 수동으로 관리하고 싶은 리소스
# - 다른 Terraform 프로젝트로 이관
```

### State 가져오기/내보내기

```bash
# State를 JSON으로 내보내기
terraform state pull > backup.tfstate

# 외부 State를 가져오기 (주의!)
terraform state push backup.tfstate
```

---

## 4. Import (기존 리소스 가져오기)

이미 존재하는 인프라를 Terraform으로 관리하기 시작할 때 사용한다.

### 전통적 방식 (import 명령어)

```bash
# 1. 먼저 .tf 파일에 리소스 블록 작성
# resource "docker_container" "existing" {
#   name = "my-existing-container"
#   image = "..."
# }

# 2. import 명령어로 State에 연결
terraform import docker_container.existing CONTAINER_ID
```

### 모던 방식 (import 블록) - Terraform 1.5+

```hcl
# .tf 파일에서 선언적으로 import
import {
  to = docker_container.existing
  id = "container-id-here"
}

resource "docker_container" "existing" {
  name  = "my-existing-container"
  image = docker_image.nginx.image_id
}
```

---

## 5. State 백업 & 복구

### 자동 백업

```bash
# Terraform은 apply 시 자동으로 백업 생성
terraform.tfstate          # 현재 상태
terraform.tfstate.backup   # 직전 상태

# 백업에서 복구
cp terraform.tfstate.backup terraform.tfstate
```

### 수동 백업

```bash
# State 파일 직접 백업
terraform state pull > backup_$(date +%Y%m%d_%H%M%S).tfstate

# 복구
terraform state push backup_20260209_160000.tfstate
```

---

## 6. Remote State 개념

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ 개발자 A      │     │ 개발자 B     │     │  CI/CD       │
└──────┬──────┘     └──────┬──────┘     └──────┬──────┘
       │                   │                   │
       └───────────┬───────┘───────────────────┘
                   │
            ┌──────▼──────┐
            │ Remote State │
            │  (S3, GCS,   │
            │   TF Cloud)  │
            └─────────────┘
```

### Local State vs Remote State

| 구분 | Local State | Remote State |
|------|-------------|--------------|
| 저장 위치 | 로컬 파일 | S3, GCS, TF Cloud 등 |
| 팀 협업 | ❌ 어려움 | ✅ 중앙 관리 |
| 잠금(Lock) | ❌ 없음 | ✅ 동시 수정 방지 |
| 보안 | ⚠️ 로컬 파일 | ✅ 암호화 가능 |
| 백업 | 수동 | 자동 |

### Remote State 설정 예시 (참고용)

```hcl
# ⚠️ 이 가이드에서는 로컬 State를 사용합니다
# 실제 프로젝트에서는 Remote State를 권장합니다

# S3 백엔드 예시
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "prod/terraform.tfstate"
    region = "ap-northeast-2"

    # DynamoDB로 State 잠금
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

---

## ⚠️ State 관리 주의사항

1. **State 파일을 직접 편집하지 마라** → `terraform state` 명령어 사용
2. **State 파일을 Git에 커밋하지 마라** → 민감 정보 포함 가능
3. **팀 프로젝트는 Remote State 사용** → 동시 수정 방지
4. **State 조작 전 반드시 백업** → `terraform state pull > backup.tfstate`

---

## 📝 핵심 정리

1. **State**는 코드(원하는 상태)와 실제 인프라를 연결하는 매핑 파일
2. `terraform state list/show`로 현재 관리 중인 리소스 확인
3. `terraform state mv/rm`으로 State를 안전하게 조작
4. `import`로 기존 인프라를 Terraform 관리 하에 편입
5. 팀 프로젝트에서는 **Remote State** (S3, GCS, TF Cloud) 사용 필수

---

## ✅ 실습 확인

```bash
cd step06_state

terraform init
terraform validate
terraform apply -auto-approve

# State 명령어 실습
terraform state list
terraform state show docker_container.web
terraform state pull > backup.tfstate

# 출력 확인
terraform output

# 정리
terraform destroy -auto-approve
rm -f backup.tfstate
```

---

## ➡️ 다음 단계

[Step 07: 모듈 (Modules)](../step07_modules/README.md)에서 재사용 가능한 인프라 컴포넌트를 만드는 방법을 배운다.
