<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
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
| [docker_network.app](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_gateway"></a> [gateway](#input\_gateway) | 네트워크 게이트웨이 | `string` | `"172.30.0.1"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | 프로젝트 이름 | `string` | n/a | yes |
| <a name="input_subnet"></a> [subnet](#input\_subnet) | 네트워크 서브넷 | `string` | `"172.30.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_network_id"></a> [network\_id](#output\_network\_id) | 네트워크 ID |
| <a name="output_network_name"></a> [network\_name](#output\_network\_name) | 생성된 네트워크 이름 |
<!-- END_TF_DOCS -->
