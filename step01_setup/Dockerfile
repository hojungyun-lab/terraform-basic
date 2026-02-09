# Terraform 실습 환경 Docker 이미지
# Terraform CLI + Docker CLI를 포함한 실습 컨테이너

FROM hashicorp/terraform:1.14

# Docker CLI 설치 (호스트 Docker 소켓과 연결하여 사용)
RUN apk add --no-cache \
    docker-cli \
    curl \
    bash \
    git \
    jq

# 작업 디렉토리 설정
WORKDIR /workspace

# 기본 셸을 bash로 설정
SHELL ["/bin/bash", "-c"]

# 컨테이너가 종료되지 않도록 유지
ENTRYPOINT ["tail", "-f", "/dev/null"]
