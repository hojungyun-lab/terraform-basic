# Step 03: Terraform 기본 명령어

## 📚 학습 목표
- Terraform의 핵심 CLI 명령어를 마스터한다
- 전체 라이프사이클(init → plan → apply → destroy)을 이해한다
- 유틸리티 명령어를 활용한다
- 디버깅 및 상태 확인 명령어를 학습한다

---

## 1. 핵심 라이프사이클 명령어

### terraform init

프로젝트를 **초기화**하고 필요한 프로바이더를 다운로드한다.

```bash
# 기본 초기화
terraform init

# 프로바이더 업그레이드
terraform init -upgrade

# 백엔드 재설정
terraform init -reconfigure

# 플러그인 미러 사용 (오프라인 환경)
terraform init -plugin-dir=/path/to/plugins
```

**실행 시점**: 프로젝트 최초 실행, provider 변경, 모듈 추가/변경 시

---

### terraform plan

변경 사항을 **미리 확인**한다 (Dry Run).

```bash
# 기본 플랜
terraform plan

# 플랜을 파일로 저장
terraform plan -out=tfplan

# 특정 변수 지정
terraform plan -var="container_name=test"

# 삭제 계획 확인
terraform plan -destroy

# JSON 형태로 출력
terraform plan -json
```

**Plan 출력 읽기**:
```
# 리소스 분류
+ create    (새로 생성)
~ update    (변경)
- destroy   (삭제)
-/+ replace (삭제 후 재생성)

Plan: 2 to add, 0 to change, 0 to destroy.
```

---

### terraform apply

Plan을 **실제로 적용**한다.

```bash
# 대화형 적용 (확인 메시지 표시)
terraform apply

# 자동 승인 (CI/CD에서 사용)
terraform apply -auto-approve

# 저장된 플랜 파일로 적용
terraform apply tfplan

# 특정 리소스만 적용
terraform apply -target=docker_container.web

# 병렬 실행 수 조정 (기본: 10)
terraform apply -parallelism=5
```

---

### terraform destroy

생성한 리소스를 **모두 삭제**한다.

```bash
# 대화형 삭제 (확인 메시지 표시)
terraform destroy

# 자동 승인
terraform destroy -auto-approve

# 특정 리소스만 삭제
terraform destroy -target=docker_container.web
```

---

## 2. 유틸리티 명령어

### terraform fmt

코드를 **표준 형식으로 정리**한다.

```bash
# 현재 디렉토리의 .tf 파일 형식 정리
terraform fmt

# 재귀적 형식 정리
terraform fmt -recursive

# 변경 필요한 파일만 확인 (수정하지 않음)
terraform fmt -check

# 변경된 파일 목록 출력
terraform fmt -diff
```

---

### terraform validate

설정 파일의 **문법 오류를 검사**한다.

```bash
# 유효성 검사
terraform validate

# JSON 형태로 결과 출력
terraform validate -json
```

> 💡 `terraform validate`는 문법만 검사한다. 실제 리소스 생성 가능 여부는 `terraform plan`으로 확인한다.

---

### terraform output

출력 값을 **조회**한다.

```bash
# 모든 출력 값 조회
terraform output

# 특정 출력 값 조회
terraform output container_name

# JSON 형태로 출력
terraform output -json

# 값만 출력 (따옴표 없이)
terraform output -raw container_name
```

---

### terraform show

현재 **State 또는 Plan의 상세 정보**를 표시한다.

```bash
# 현재 상태 표시
terraform show

# JSON 형태로 표시
terraform show -json

# 저장된 플랜 파일 내용 확인
terraform show tfplan
```

---

## 3. 상태 관리 명령어

### terraform state

State 파일을 **직접 조작**한다.

```bash
# State의 리소스 목록 확인
terraform state list

# 특정 리소스 상세 정보
terraform state show docker_container.web

# 리소스를 State에서 제거 (실제 인프라는 유지)
terraform state rm docker_container.web

# 리소스 이름 변경
terraform state mv docker_container.old docker_container.new

# State를 파일로 내보내기
terraform state pull > backup.tfstate
```

---

## 4. 디버깅 & 고급 명령어

### terraform console

**대화형 콘솔**에서 표현식을 테스트한다.

```bash
terraform console

# 콘솔 내에서 실행
> var.container_name
"my-container"

> length(["a", "b", "c"])
3

> upper("hello")
"HELLO"

> exit
```

---

### terraform graph

리소스 간 **의존성 그래프**를 생성한다.

```bash
# DOT 형태로 출력
terraform graph

# Graphviz로 이미지 생성 (graphviz 설치 필요)
terraform graph | dot -Tpng > graph.png
```

---

### terraform providers

사용 중인 **프로바이더 정보**를 확인한다.

```bash
# 프로바이더 목록
terraform providers

# 프로바이더 잠금 파일 업데이트
terraform providers lock

# 프로바이더 미러링 (오프라인 사용)
terraform providers mirror /path/to/mirror
```

---

## 5. 명령어 빠른 참조

| 명령어 | 용도 | 자주 사용하는 옵션 |
|--------|------|-------------------|
| `init` | 초기화 | `-upgrade` |
| `plan` | 미리보기 | `-out=FILE` |
| `apply` | 적용 | `-auto-approve` |
| `destroy` | 삭제 | `-auto-approve` |
| `fmt` | 코드 포매팅 | `-recursive` |
| `validate` | 문법 검사 | `-json` |
| `output` | 출력 조회 | `-raw` |
| `show` | 상태 표시 | `-json` |
| `state list` | State 목록 | - |
| `state show` | State 상세 | `RESOURCE` |
| `console` | 대화형 콘솔 | - |
| `graph` | 의존성 그래프 | - |

---

## 📝 핵심 정리

1. **기본 라이프사이클**: `init` → `plan` → `apply` → `destroy`
2. **fmt + validate**로 코드 품질 유지
3. **plan -out**으로 미리 저장하고 **apply tfplan**으로 안전하게 적용
4. **state** 명령어로 State 파일 직접 관리
5. **console**로 표현식 테스트, **graph**로 의존성 시각화

---

## ✅ 실습 확인

```bash
cd step03_commands

# 전체 라이프사이클 실행
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan

# 상태 확인
terraform state list
terraform state show docker_container.web
terraform output

# 정리
terraform destroy -auto-approve
rm -f tfplan
```

---

## ➡️ 다음 단계

[Step 04: Variables & Outputs](../step04_variables/README.md)에서 변수와 출력을 체계적으로 관리하는 방법을 배운다.
