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
| [docker_container.app](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/container) | resource |
| [docker_container.cache](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/container) | resource |
| [docker_image.app](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/image) | resource |
| [docker_image.redis](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/image) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_port"></a> [app\_port](#input\_app\_port) | 앱 서버 외부 포트 | `number` | `8101` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | 컨테이너 라벨 | `map(string)` | `{}` | no |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | Docker 네트워크 이름 | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | 프로젝트 이름 | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_container_id"></a> [app\_container\_id](#output\_app\_container\_id) | 앱 서버 컨테이너 ID |
| <a name="output_app_container_name"></a> [app\_container\_name](#output\_app\_container\_name) | 앱 서버 컨테이너 이름 |
| <a name="output_cache_container_id"></a> [cache\_container\_id](#output\_cache\_container\_id) | 캐시 서버 컨테이너 ID |
| <a name="output_cache_container_name"></a> [cache\_container\_name](#output\_cache\_container\_name) | 캐시 서버 컨테이너 이름 |
<!-- END_TF_DOCS -->
