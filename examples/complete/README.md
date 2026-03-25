# complete

This example creates a complete deployment of the `azurerm_monitor_autoscale_setting` primitive module,
targeting an Azure App Service Plan with CPU-based scale-out and scale-in rules.

## Usage

```hcl
module "resource_names" {
  source  = "terraform.registry.launch.nttdata.com/module_library/resource_name/launch"
  version = "~> 2.0"

  for_each = var.resource_names_map

  logical_product_family  = var.product_family
  logical_product_service = var.product_service
  region                  = var.location
  class_env               = var.environment
  cloud_resource_type     = each.value.name
  instance_env            = var.environment_number
  instance_resource       = var.resource_number
  maximum_length          = each.value.max_length
  use_azure_region_abbr   = var.use_azure_region_abbr
}

module "resource_group" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/resource_group/azurerm"
  version = "~> 1.0"

  name     = module.resource_names["resource_group"].standard
  location = var.location

  tags = merge(var.tags, { resource_name = module.resource_names["resource_group"].standard })
}

resource "azurerm_service_plan" "app_service_plan" {
  name                = module.resource_names["app_service_plan"].standard
  resource_group_name = module.resource_group.name
  location            = var.location
  os_type             = var.app_service_plan_os_type
  sku_name            = var.app_service_plan_sku_name

  tags = merge(var.tags, { resource_name = module.resource_names["app_service_plan"].standard })

  depends_on = [module.resource_group]
}

locals {
  resolved_profiles = [
    for p in var.profiles : merge(p, {
      rules = p.rules == null ? null : [
        for r in p.rules : merge(r, {
          metric_trigger = merge(r.metric_trigger, {
            metric_resource_id = coalesce(r.metric_trigger.metric_resource_id, azurerm_service_plan.app_service_plan.id)
          })
        })
      ]
    })
  ]
}

module "monitor_autoscale_setting" {
  source = "../.."

  name                = module.resource_names["monitor_autoscale_setting"].standard
  resource_group_name = module.resource_group.name
  location            = var.location
  target_resource_id  = azurerm_service_plan.app_service_plan.id
  enabled             = var.enabled
  profiles            = local.resolved_profiles
  notification        = var.notification
  predictive          = var.predictive
  tags                = merge(var.tags, { resource_name = module.resource_names["monitor_autoscale_setting"].standard })

  depends_on = [module.resource_group, azurerm_service_plan.app_service_plan]
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.113 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.113 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resource_names"></a> [resource\_names](#module\_resource\_names) | terraform.registry.launch.nttdata.com/module_library/resource_name/launch | ~> 2.0 |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | terraform.registry.launch.nttdata.com/module_primitive/resource_group/azurerm | ~> 1.0 |
| <a name="module_monitor_autoscale_setting"></a> [monitor\_autoscale\_setting](#module\_monitor\_autoscale\_setting) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_service_plan.app_service_plan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_product_family"></a> [product\_family](#input\_product\_family) | (Required) Name of the product family for which the resource is created. Example: org\_name, department\_name. | `string` | `"dso"` | no |
| <a name="input_product_service"></a> [product\_service](#input\_product\_service) | (Required) Name of the product service for which the resource is created. For example, backend, frontend, middleware etc. | `string` | `"mon"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment in which the resource should be provisioned like dev, qa, prod etc. | `string` | `"dev"` | no |
| <a name="input_environment_number"></a> [environment\_number](#input\_environment\_number) | The environment count for the respective environment. Defaults to 1. Increments in value of 1. | `number` | `1` | no |
| <a name="input_resource_number"></a> [resource\_number](#input\_resource\_number) | The resource count for the respective resource. Defaults to 1. Increments in value of 1. | `number` | `1` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region where the resources will be created. | `string` | `"eastus"` | no |
| <a name="input_use_azure_region_abbr"></a> [use\_azure\_region\_abbr](#input\_use\_azure\_region\_abbr) | Whether to use Azure region abbreviations in resource names (e.g. eus for eastus). | `bool` | `true` | no |
| <a name="input_resource_names_map"></a> [resource\_names\_map](#input\_resource\_names\_map) | A map of key to resource\_name that will be used by tf-launch-module\_library-resource\_name to generate resource names. | `map(object({...}))` | see default | no |
| <a name="input_app_service_plan_os_type"></a> [app\_service\_plan\_os\_type](#input\_app\_service\_plan\_os\_type) | The O/S type for the App Service Plan (Linux or Windows). | `string` | `"Linux"` | no |
| <a name="input_app_service_plan_sku_name"></a> [app\_service\_plan\_sku\_name](#input\_app\_service\_plan\_sku\_name) | The SKU for the App Service Plan (must be a scalable SKU such as S1, S2, P1v2 etc.). | `string` | `"S1"` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Specifies whether automatic scaling is enabled for the target resource. | `bool` | `true` | no |
| <a name="input_profiles"></a> [profiles](#input\_profiles) | One or more profile blocks (up to 20) defining the autoscale behavior. | `list(object({...}))` | see default | no |
| <a name="input_notification"></a> [notification](#input\_notification) | Optional notification configuration for scale events. | `object({...})` | `null` | no |
| <a name="input_predictive"></a> [predictive](#input\_predictive) | Optional predictive autoscale configuration. | `object({...})` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the AutoScale Setting. |
| <a name="output_name"></a> [name](#output\_name) | The name of the AutoScale Setting. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group containing the AutoScale Setting. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
