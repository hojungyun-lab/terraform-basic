<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_docker"></a> [docker](#requirement\_docker) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_docker"></a> [docker](#provider\_docker) | 3.6.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [docker_container.this](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/container) | resource |
| [docker_image.this](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/image) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | Docker 컨테이너 이름 | `string` | n/a | yes |
| <a name="input_env_vars"></a> [env\_vars](#input\_env\_vars) | 환경 변수 리스트 | `list(string)` | `[]` | no |
| <a name="input_external_port"></a> [external\_port](#input\_external\_port) | 호스트 외부 포트 | `number` | n/a | yes |
| <a name="input_image"></a> [image](#input\_image) | Docker 이미지 이름:태그 | `string` | `"nginx:alpine"` | no |
| <a name="input_internal_port"></a> [internal\_port](#input\_internal\_port) | 컨테이너 내부 포트 | `number` | `80` | no |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | 연결할 Docker 네트워크 이름 (빈 문자열이면 연결 안 함) | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_id"></a> [container\_id](#output\_container\_id) | 생성된 컨테이너 ID |
| <a name="output_container_name"></a> [container\_name](#output\_container\_name) | 컨테이너 이름 |
| <a name="output_image_id"></a> [image\_id](#output\_image\_id) | 사용된 이미지 ID |
<!-- END_TF_DOCS -->
