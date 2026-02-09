# Step 08: 조건문, 반복문, 동적 블록

## 📚 학습 목표
- `count`와 `for_each`로 리소스를 반복 생성한다
- `for` 표현식으로 데이터를 변환한다
- 조건 표현식으로 동적 설정을 구현한다
- `dynamic` 블록으로 중첩 블록을 동적 생성한다
- `locals`를 활용하여 복잡한 로직을 관리한다

---

## 1. count - 숫자 기반 반복

### 기본 사용법

```hcl
# 동일한 리소스를 N개 생성
resource "docker_container" "web" {
  count = 3

  name  = "web-${count.index}"    # web-0, web-1, web-2
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = 8100 + count.index  # 8100, 8101, 8102
  }
}

# 참조: 인덱스로 접근
output "first_container" {
  value = docker_container.web[0].name  # "web-0"
}

# 전체 목록
output "all_names" {
  value = docker_container.web[*].name  # ["web-0", "web-1", "web-2"]
}
```

### 조건부 생성

```hcl
variable "create_container" {
  type    = bool
  default = true
}

# count = 0 이면 생성하지 않음
resource "docker_container" "optional" {
  count = var.create_container ? 1 : 0
  name  = "optional-container"
  image = docker_image.nginx.image_id
}
```

---

## 2. for_each - 맵/셋 기반 반복

### Map으로 반복

```hcl
variable "containers" {
  type = map(object({
    image = string
    port  = number
  }))
  default = {
    web = {
      image = "nginx:alpine"
      port  = 8110
    }
    api = {
      image = "httpd:alpine"
      port  = 8111
    }
  }
}

resource "docker_container" "app" {
  for_each = var.containers

  name  = "foreach-${each.key}"     # foreach-web, foreach-api
  image = docker_image.images[each.key].image_id

  ports {
    internal = 80
    external = each.value.port       # 8110, 8111
  }
}
```

### Set으로 반복

```hcl
variable "container_names" {
  type    = set(string)
  default = ["alpha", "beta", "gamma"]
}

resource "docker_container" "named" {
  for_each = var.container_names

  name  = "set-${each.key}"
  image = docker_image.nginx.image_id
}
```

### count vs for_each

| 구분 | count | for_each |
|------|-------|----------|
| 참조 | 인덱스 `[0]`, `[1]` | 키 `["web"]`, `["api"]` |
| 입력 | 숫자 | map 또는 set |
| 요소 삭제 | ⚠️ 인덱스 쉬프트 | ✅ 키 기반으로 안전 |
| 권장 | 동일한 리소스 N개 | 서로 다른 설정의 리소스 |

---

## 3. for 표현식

### 리스트 변환

```hcl
locals {
  names = ["web", "api", "db"]
  
  # 리스트 → 리스트 변환
  upper_names = [for n in local.names : upper(n)]
  # ["WEB", "API", "DB"]
  
  # 조건부 필터링
  filtered = [for n in local.names : upper(n) if n != "db"]
  # ["WEB", "API"]
}
```

### 맵 변환

```hcl
locals {
  ports = {
    web = 8080
    api = 8081
    db  = 5432
  }
  
  # 맵 → 맵 변환
  urls = { for k, v in local.ports : k => "http://localhost:${v}" }
  # { web = "http://localhost:8080", api = "http://localhost:8081", db = "http://localhost:5432" }
  
  # 맵 → 리스트 변환
  port_list = [for k, v in local.ports : "${k}:${v}"]
  # ["web:8080", "api:8081", "db:5432"]
}
```

---

## 4. 조건 표현식 (Conditional)

```hcl
variable "environment" {
  type    = string
  default = "dev"
}

locals {
  # 삼항 연산자
  is_prod     = var.environment == "prod"
  port        = local.is_prod ? 80 : 8080
  replica_count = local.is_prod ? 3 : 1
  
  # 복합 조건
  log_level = (
    var.environment == "prod" ? "error" :
    var.environment == "staging" ? "warn" :
    "debug"
  )
}
```

---

## 5. dynamic 블록

### 기본 사용법

```hcl
variable "ports" {
  type = list(object({
    internal = number
    external = number
  }))
  default = [
    { internal = 80, external = 8080 },
    { internal = 443, external = 8443 }
  ]
}

resource "docker_container" "web" {
  name  = "dynamic-demo"
  image = docker_image.nginx.image_id

  # 동적으로 ports 블록 생성
  dynamic "ports" {
    for_each = var.ports
    content {
      internal = ports.value.internal
      external = ports.value.external
    }
  }
}
```

### labels 동적 생성

```hcl
variable "labels" {
  type = map(string)
  default = {
    project     = "terraform-learning"
    environment = "dev"
    managed_by  = "terraform"
  }
}

resource "docker_container" "labeled" {
  name  = "labeled-demo"
  image = docker_image.nginx.image_id

  dynamic "labels" {
    for_each = var.labels
    content {
      label = labels.key
      value = labels.value
    }
  }
}
```

---

## 6. 내장 함수 활용

### 자주 사용하는 함수

| 카테고리 | 함수 | 예시 |
|----------|------|------|
| 문자열 | `upper`, `lower`, `format` | `upper("hello")` → `"HELLO"` |
| 문자열 | `join`, `split`, `replace` | `join("-", ["a","b"])` → `"a-b"` |
| 컬렉션 | `length`, `contains`, `lookup` | `length([1,2,3])` → `3` |
| 컬렉션 | `merge`, `concat`, `flatten` | `merge({a=1}, {b=2})` |
| 숫자 | `min`, `max`, `abs` | `max(5, 12)` → `12` |
| 타입 | `tostring`, `tolist`, `tomap` | `tostring(42)` → `"42"` |
| 파일 | `file`, `templatefile` | `file("script.sh")` |
| 인코딩 | `jsonencode`, `jsondecode` | `jsonencode({a=1})` |

```hcl
locals {
  # merge로 맵 병합
  all_labels = merge(
    var.common_labels,
    { created_by = "step08" }
  )
  
  # format으로 문자열 포매팅
  container_name = format("%s-%s-%02d", var.project, var.environment, 1)
  
  # flatten으로 중첩 리스트 평탄화
  all_ports = flatten([
    [80, 443],
    [8080, 8081]
  ])
}
```

---

## 📝 핵심 정리

1. **count**: 동일 리소스 N개 생성, 조건부 생성 (`count = var.flag ? 1 : 0`)
2. **for_each**: Map/Set 기반 반복, 키로 참조하여 안전한 삭제
3. **for**: 데이터 변환 `[for x in list : transform(x)]`
4. **조건문**: `condition ? true_value : false_value`
5. **dynamic**: 중첩 블록을 동적으로 생성
6. **내장 함수**: 풍부한 함수 라이브러리 활용

---

## ✅ 실습 확인

```bash
cd step08_advanced_hcl

terraform init
terraform validate
terraform plan
terraform apply -auto-approve

# 생성된 컨테이너 확인
docker ps | grep advanced-

# 출력 확인
terraform output

# 정리
terraform destroy -auto-approve
```

---

## ➡️ 다음 단계

[Step 09: Provisioners & 외부 연동](../step09_provisioners/README.md)에서 외부 스크립트 연동과 Provisioner를 학습한다.
