# Step 09: Provisioners & 외부 연동

## 📚 학습 목표
- `local-exec`와 `remote-exec` Provisioner를 이해한다
- `null_resource`로 커스텀 작업을 수행한다
- `external` 데이터 소스로 외부 스크립트를 연동한다
- `templatefile` 함수로 동적 파일을 생성한다
- Provisioner의 한계와 대안을 이해한다

---

## 1. Provisioner란?

### 개념

**Provisioner**는 리소스 생성/삭제 시 **추가 작업**을 수행하는 메커니즘이다.

```
리소스 생성 (terraform apply)
    │
    ▼
Provisioner 실행 (스크립트, 명령어 등)
    │
    ▼
완료
```

> ⚠️ **HashiCorp 공식 입장**: Provisioner는 "최후의 수단"이다. 가능하면 네이티브 리소스 속성이나 모듈을 사용하라.

### Provisioner 종류

| 종류 | 실행 위치 | 용도 |
|------|-----------|------|
| `local-exec` | Terraform 실행 머신 | 로컬 스크립트/명령어 |
| `remote-exec` | 대상 리소스 | SSH/WinRM으로 원격 명령 |
| `file` | 대상 리소스 | 파일 복사 |

---

## 2. local-exec Provisioner

로컬 머신에서 명령어를 실행한다.

```hcl
resource "docker_container" "web" {
  name  = "provisioner-demo"
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = 8092
  }

  # 컨테이너 생성 후 실행
  provisioner "local-exec" {
    command = "echo '컨테이너 ${self.name} 생성 완료! ID: ${self.id}'"
  }

  # 컨테이너 삭제 시 실행
  provisioner "local-exec" {
    when    = destroy
    command = "echo '컨테이너 ${self.name} 삭제됨'"
  }
}
```

### 고급 옵션

```hcl
provisioner "local-exec" {
  command     = "bash ./scripts/setup.sh"
  working_dir = path.module          # 실행 디렉토리
  interpreter = ["/bin/bash", "-c"]  # 인터프리터 지정

  environment = {
    CONTAINER_NAME = self.name
    CONTAINER_ID   = self.id
  }

  # 실패 시 동작
  on_failure = continue  # 또는 fail (기본값)
}
```

---

## 3. null_resource

실제 인프라를 생성하지 않는 **가상 리소스**. Provisioner를 실행할 때 유용하다.

```hcl
resource "null_resource" "health_check" {
  # triggers가 변경될 때마다 재실행
  triggers = {
    container_id = docker_container.web.id
    timestamp    = timestamp()
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "헬스 체크 실행..."
      sleep 2
      curl -s -o /dev/null -w "%%{http_code}" http://localhost:8092 || echo "서버 응답 대기 중"
      echo "헬스 체크 완료!"
    EOT
  }

  depends_on = [docker_container.web]
}
```

### terraform_data (Terraform 1.4+, null_resource 대체)

```hcl
resource "terraform_data" "health_check" {
  triggers_replace = [docker_container.web.id]

  provisioner "local-exec" {
    command = "echo '헬스 체크: ${docker_container.web.name}'"
  }
}
```

---

## 4. external 데이터 소스

외부 프로그램의 결과를 Terraform에서 사용한다.

```hcl
# 외부 스크립트 실행 결과를 데이터로 사용
data "external" "system_info" {
  program = ["bash", "${path.module}/scripts/system_info.sh"]

  query = {
    check_type = "docker"
  }
}

output "system_info" {
  value = data.external.system_info.result
}
```

### 외부 스크립트 규칙

```bash
#!/bin/bash
# scripts/system_info.sh
# 규칙: stdin으로 JSON 받고, stdout으로 JSON 출력

# stdin에서 query 읽기
INPUT=$(cat)

# JSON 형태로 결과 출력 (반드시 문자열 값만!)
cat <<EOF
{
  "docker_version": "$(docker --version 2>/dev/null | head -1 || echo 'not installed')",
  "terraform_version": "$(terraform --version 2>/dev/null | head -1 || echo 'not installed')",
  "hostname": "$(hostname)",
  "os": "$(uname -s)"
}
EOF
```

---

## 5. templatefile 함수

템플릿 파일에 변수를 주입하여 동적 내용을 생성한다.

```hcl
# 템플릿 파일에 변수 전달
locals {
  nginx_config = templatefile("${path.module}/templates/nginx.conf.tpl", {
    server_name = "my-app.local"
    port        = 80
    upstream    = "backend"
  })
}
```

### 템플릿 파일 문법

```nginx
# templates/nginx.conf.tpl
server {
    listen ${port};
    server_name ${server_name};

    location / {
        proxy_pass http://${upstream};
    }
}
```

---

## 6. Provisioner 사용 시 주의사항

### ⚠️ 주의

| 주의사항 | 설명 |
|----------|------|
| **비멱등성** | 같은 명령이 매번 같은 결과를 보장하지 않음 |
| **State 미추적** | Provisioner 결과는 State에 저장되지 않음 |
| **실패 시 복잡** | 실패해도 리소스는 이미 생성된 상태 |
| **재현성** | 다른 환경에서 같은 결과 보장 불가 |

### ✅ 대안

| 상황 | 대안 |
|------|------|
| 서버 설정 | Ansible, Chef, Puppet |
| 컨테이너 설정 | Dockerfile, docker-compose |
| 앱 배포 | CI/CD 파이프라인 |
| 초기 데이터 | 전용 리소스 (예: `aws_ssm_parameter`) |

---

## 📝 핵심 정리

1. **local-exec**: 로컬에서 명령어 실행 (배포 후 알림, 스크립트 등)
2. **null_resource / terraform_data**: Provisioner 실행을 위한 가상 리소스
3. **external**: 외부 프로그램의 결과를 데이터 소스로 사용
4. **templatefile**: 템플릿 파일에 변수를 주입하여 동적 내용 생성
5. Provisioner는 **최후의 수단** → 가능하면 네이티브 방법 사용

---

## ✅ 실습 확인

```bash
cd step09_provisioners

# 스크립트 실행 권한 부여
chmod +x scripts/*.sh

terraform init
terraform validate
terraform plan
terraform apply -auto-approve

# 출력 확인
terraform output

# 정리
terraform destroy -auto-approve
```

---

## ➡️ 다음 단계

[Step 10: 워크스페이스 & 환경 분리](../step10_workspaces/README.md)에서 환경을 분리하여 관리하는 방법을 배운다.
