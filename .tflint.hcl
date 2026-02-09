# TFLint 설정 파일
# https://github.com/terraform-linters/tflint

config {
  # Terraform 모듈 검사
  call_module_type = "local"
}

# Terraform 기본 규칙
plugin "terraform" {
  enabled = true
  preset  = "recommended"
}
