# Step 05: 데이터 소스 & 프로바이더

## 📚 학습 목표
- 데이터 소스(Data Source)로 기존 리소스 정보를 조회한다
- 프로바이더 버전을 관리하고 고정한다
- `terraform` 블록의 설정을 심층 이해한다
- 여러 프로바이더 인스턴스를 활용한다

---

## 1. 데이터 소스 (Data Sources)

### 개념

**Data Source**는 Terraform 외부에서 관리되는 기존 리소스의 정보를 **읽기 전용**으로 조회한다.

```
리소스 (resource)  = "생성/관리한다" (CRUD)
데이터 소스 (data)  = "조회만 한다" (Read-only)
```

### 기본 문법

```hcl
# data "타입" "이름" { ... }
data "docker_image" "latest_nginx" {
  name = "nginx:latest"
}

# 참조: data.타입.이름.속성
output "image_id" {
  value = data.docker_image.latest_nginx.id
}
```

### Docker 데이터 소스 예시

```hcl
# 기존 Docker 네트워크 정보 조회
data "docker_network" "bridge" {
  name = "bridge"
}

output "bridge_network_id" {
  value = data.docker_network.bridge.id
}

# 기존 Docker 이미지 정보 조회
data "docker_image" "existing" {
  name = "nginx:alpine"
}
```

### Resource vs Data Source

| 구분 | Resource | Data Source |
|------|----------|------------|
| 키워드 | `resource` | `data` |
| 동작 | 생성/수정/삭제 | 읽기 전용 |
| 라이프사이클 | Terraform이 관리 | 외부에서 관리 |
| 참조 | `리소스타입.이름.속성` | `data.타입.이름.속성` |
| 용도 | 새 인프라 생성 | 기존 인프라 참조 |

---

## 2. 프로바이더 설정 심화

### required_providers 블록

```hcl
terraform {
  # Terraform 자체 버전 제약
  required_version = ">= 1.0, < 2.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"    # 3.x 최신 (3.0.0 이상, 4.0.0 미만)
    }
  }
}
```

### 버전 제약 조건

| 연산자 | 의미 | 예시 |
|--------|------|------|
| `=` | 정확히 일치 | `= 3.0.2` |
| `!=` | 제외 | `!= 3.0.1` |
| `>`, `>=` | 이상 | `>= 3.0` |
| `<`, `<=` | 이하 | `< 4.0` |
| `~>` | 마이너 버전까지 허용 | `~> 3.0` = `>= 3.0, < 4.0` |

```hcl
# 버전 제약 예시
version = "~> 3.0"      # 3.x 아무 버전 (권장)
version = "~> 3.0.2"    # 3.0.x (3.0.2 이상)
version = ">= 3.0, < 4.0"  # 명시적 범위
version = "= 3.0.2"     # 정확히 이 버전만
```

### 프로바이더 잠금 파일

```bash
# .terraform.lock.hcl - 자동 생성
# 팀 전체가 같은 버전을 사용하도록 보장
# ⚠️ Git에 반드시 커밋해야 함!
```

---

## 3. 프로바이더 설정 (Provider Configuration)

### Provider 블록

```hcl
# Docker Provider 기본 설정
provider "docker" {
  # macOS/Linux: 기본 소켓 자동 감지
  # 명시적 설정이 필요한 경우:
  host = "unix:///var/run/docker.sock"
}
```

### 별칭(Alias)을 사용한 다중 프로바이더

```hcl
# 기본 프로바이더
provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# 별칭이 있는 두 번째 프로바이더
provider "docker" {
  alias = "remote"
  host  = "tcp://remote-host:2376"
}

# 기본 프로바이더 사용
resource "docker_container" "local_web" {
  name  = "local-web"
  image = docker_image.nginx.image_id
}

# 별칭 프로바이더 사용
resource "docker_container" "remote_web" {
  provider = docker.remote
  name     = "remote-web"
  image    = docker_image.nginx.image_id
}
```

---

## 4. terraform 블록 심화

```hcl
terraform {
  # Terraform CLI 버전 제약
  required_version = ">= 1.0"

  # 필요한 프로바이더 선언
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }

  # 백엔드 설정 (State 저장 위치)
  # backend "local" {
  #   path = "terraform.tfstate"
  # }

  # 실험적 기능 활성화 (선택)
  # experiments = [module_variable_optional_attrs]
}
```

---

## 📝 핵심 정리

1. **Data Source**는 기존 리소스를 읽기 전용으로 조회: `data "타입" "이름" { }`
2. **version**으로 프로바이더 버전을 고정하여 안정성 확보
3. **`~> 3.0`** 형태가 가장 권장되는 버전 제약 방식
4. **alias**로 같은 프로바이더의 다중 인스턴스 관리
5. `.terraform.lock.hcl`은 **반드시 Git에 커밋**

---

## ✅ 실습 확인

```bash
cd step05_datasources

terraform init
terraform validate
terraform plan
terraform apply -auto-approve

# 데이터 소스 조회 결과 확인
terraform output

# 정리
terraform destroy -auto-approve
```

---

## ➡️ 다음 단계

[Step 06: State 관리](../step06_state/README.md)에서 Terraform State의 구조와 관리 방법을 배운다.
