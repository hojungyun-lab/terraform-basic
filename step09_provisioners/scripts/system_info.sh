#!/bin/bash
# system_info.sh - external 데이터 소스용 스크립트
# 규칙: stdout으로 JSON 문자열 맵을 출력해야 한다

# stdin으로 들어오는 query 파라미터 읽기 (사용하지 않더라도 읽어야 함)
INPUT=$(cat)

# 시스템 정보를 JSON 형태로 출력
cat <<EOF
{
  "hostname": "$(hostname)",
  "os": "$(uname -s)",
  "arch": "$(uname -m)",
  "docker_version": "$(docker --version 2>/dev/null | awk '{print $3}' | tr -d ',' || echo 'not-installed')",
  "terraform_version": "$(terraform --version 2>/dev/null | head -1 | awk '{print $2}' || echo 'not-installed')"
}
EOF
