# Step 01: 환경 설정 (Docker + Terraform)

## 📚 학습 목표
- Terraform CLI를 설치한다
- Docker Desktop을 설치하고 구성한다
- Docker Provider를 이해한다
- 첫 번째 `terraform init`을 실행한다
- Docker 기반 실습 환경을 구축한다

---

## 1. Terraform 설치

### macOS (Homebrew)

```bash
# Homebrew로 설치 (권장)
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# 설치 확인
terraform version
# Terraform v1.14.x
```

### Linux (Ubuntu/Debian)

```bash
# HashiCorp GPG 키 추가
wget -O- https://apt.releases.hashicorp.com/gpg | \
  sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# 저장소 추가
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
  https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/hashicorp.list

# 설치
sudo apt update && sudo apt install terraform

# 설치 확인
terraform version
```

### Windows (Chocolatey)

```powershell
# Chocolatey로 설치
choco install terraform

# 설치 확인
terraform version
```

### 수동 설치 (모든 OS)

```bash
# https://developer.hashicorp.com/terraform/install 에서 다운로드
# 압축 해제 후 PATH에 추가
unzip terraform_1.14.4_darwin_arm64.zip
sudo mv terraform /usr/local/bin/
terraform version
```

---

## 2. Docker Desktop 설치

### macOS

```bash
# Homebrew로 설치
brew install --cask docker

# 또는 공식 사이트에서 다운로드
# https://www.docker.com/products/docker-desktop
```

### Linux

```bash
# Docker Engine 설치
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 현재 사용자를 docker 그룹에 추가 (sudo 없이 사용하기 위해)
sudo usermod -aG docker $USER
newgrp docker
```

### 설치 확인

```bash
# Docker 데몬 실행 확인
docker version

# 테스트 컨테이너 실행
docker run hello-world
```

> ⚠️ **중요**: Docker Desktop(또는 Docker Engine)이 실행 중이어야 Terraform Docker Provider가 작동합니다.

---

## 3. Docker 기반 Terraform 실습 환경

Docker 자체에서 Terraform을 실행할 수 있는 컨테이너 환경을 제공한다.

### Dockerfile

이 프로젝트에 포함된 `Dockerfile`을 사용하여 Terraform + Docker CLI가 포함된 실습 환경을 구축할 수 있다.

```bash
# 실습 환경 빌드 및 실행
cd step01_setup
docker compose up -d

# 컨테이너 접속
docker exec -it terraform-lab /bin/sh

# 내부에서 Terraform 확인
terraform version
```

### 컨테이너 내부에서 실습하기

```bash
# 컨테이너 내부에서 Docker Provider 사용 시
# 호스트의 Docker 소켓을 마운트했으므로 호스트의 Docker를 제어할 수 있다

# 실습 파일 확인
ls /workspace

# 실습 종료 후
exit
docker compose down
```

---

## 4. Docker Provider 이해

### Docker Provider란?

Terraform Docker Provider(`kreuzwerker/docker`)는 Docker 리소스를 Terraform으로 관리할 수 있게 해주는 플러그인이다.

### 관리 가능한 리소스

| 리소스 | 설명 |
|--------|------|
| `docker_image` | Docker 이미지 Pull/관리 |
| `docker_container` | 컨테이너 생성/관리 |
| `docker_network` | Docker 네트워크 생성 |
| `docker_volume` | Docker 볼륨 생성 |
| `docker_registry_image` | 레지스트리 이미지 정보 |

### Provider 선언

```hcl
# terraform 블록에서 필요한 프로바이더를 선언한다
terraform {
  required_version = ">= 1.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"     # 3.x 최신 버전 사용
    }
  }
}

# 프로바이더 설정
provider "docker" {
  # Docker Desktop 사용 시 기본 소켓으로 자동 연결
  # Linux: unix:///var/run/docker.sock
  # macOS: 자동 감지
}
```

---

## 5. 첫 번째 Terraform 프로젝트

### 프로젝트 구조 생성

```bash
# 실습 디렉토리 생성
mkdir -p ~/terraform-first-project
cd ~/terraform-first-project
```

### main.tf 작성

```hcl
# main.tf - 첫 번째 Terraform 설정 파일

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

# Docker 이미지 Pull
resource "docker_image" "hello" {
  name = "hello-world:latest"
}
```

### Terraform 라이프사이클 실행

```bash
# 1. 초기화 - 프로바이더 다운로드
terraform init

# 출력 예시:
# Initializing the backend...
# Initializing provider plugins...
# - Finding kreuzwerker/docker versions matching "~> 3.0"...
# - Installing kreuzwerker/docker v3.x.x...
# Terraform has been successfully initialized!

# 2. 코드 형식 검사
terraform fmt

# 3. 설정 유효성 검사
terraform validate
# Success! The configuration is valid.

# 4. 실행 계획 확인
terraform plan
# Plan: 1 to add, 0 to change, 0 to destroy.

# 5. 적용
terraform apply -auto-approve
# Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

# 6. 현재 상태 확인
terraform show

# 7. 정리 (리소스 삭제)
terraform destroy -auto-approve
# Destroy complete! Resources: 1 destroyed.
```

---

## 6. 생성된 파일 이해

`terraform init` 실행 후 생성되는 파일/디렉토리:

```
my-project/
├── main.tf                  # 직접 작성한 설정 파일
├── .terraform/              # 프로바이더 플러그인 저장소
│   └── providers/
│       └── registry.terraform.io/
│           └── kreuzwerker/docker/
├── .terraform.lock.hcl      # 프로바이더 버전 잠금 파일
├── terraform.tfstate         # 현재 인프라 상태 (apply 후)
└── terraform.tfstate.backup  # 이전 상태 백업 (2번째 apply 후)
```

| 파일 | 역할 | Git에 포함? |
|------|------|------------|
| `*.tf` | Terraform 설정 파일 | ✅ Yes |
| `.terraform.lock.hcl` | 버전 잠금 | ✅ Yes |
| `.terraform/` | 프로바이더 바이너리 | ❌ No |
| `terraform.tfstate` | 상태 파일 | ❌ No |
| `*.tfvars` | 변수 값 (민감정보 가능) | ⚠️ 상황에 따라 |

### 권장 .gitignore

```gitignore
# Terraform
.terraform/
*.tfstate
*.tfstate.backup
*.tfvars
crash.log
override.tf
override.tf.json
*_override.tf
*_override.tf.json
```

---

## 📝 핵심 정리

1. **Terraform CLI**는 Homebrew/apt/choco 등으로 간단히 설치
2. **Docker Desktop**이 실행 중이어야 Docker Provider 사용 가능
3. **Docker Provider** (`kreuzwerker/docker`)로 컨테이너, 이미지, 네트워크 등을 관리
4. `terraform init` → `plan` → `apply` → `destroy`가 기본 워크플로우
5. `.terraform/`과 `*.tfstate`는 Git에 포함하지 않는다

---

## ✅ 실습 확인

```bash
# 이 단계의 실습 파일로 테스트
cd step01_setup

# Docker compose로 실습 환경 실행 (선택사항)
docker compose up -d

# Terraform 직접 실행
terraform init
terraform validate
terraform plan
terraform apply -auto-approve

# 결과 확인
docker images | grep hello-world

# 정리
terraform destroy -auto-approve
docker compose down  # 실습 환경 사용한 경우
```

---

## ➡️ 다음 단계

[Step 02: HCL 기초 문법](../step02_hcl_basics/README.md)에서 Terraform의 설정 언어를 배운다.
