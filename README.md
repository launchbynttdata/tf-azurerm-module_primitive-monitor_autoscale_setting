# tf-azurerm-module_primitive-monitor_autoscale_setting

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![License: CC BY-NC-ND 4.0](https://img.shields.io/badge/License-CC_BY--NC--ND_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-nd/4.0/)

## Overview

This Terraform primitive module manages an [`azurerm_monitor_autoscale_setting`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_autoscale_setting) resource.

It provides a comprehensive, production-ready wrapper that exposes all commonly-used attributes of the Azure Monitor AutoScale Setting resource, including:

- Up to 20 autoscale profiles with capacity configuration
- CPU/memory/custom metric-based scale-out and scale-in rules with full `metric_trigger` and `scale_action` control
- Fixed-date and recurring (weekly) schedule profiles
- Email and webhook notifications for scale events
- Predictive autoscale (Enabled / ForecastOnly)

## Pre-Commit hooks

[.pre-commit-config.yaml](.pre-commit-config.yaml) file defines certain `pre-commit` hooks that are relevant to terraform, golang and common linting tasks. There are no custom hooks added.

`commitlint` hook enforces commit message in certain format. The commit contains the following structural elements, to communicate intent to the consumers of your commit messages:

- **fix**: a commit of the type `fix` patches a bug in your codebase (this correlates with PATCH in Semantic Versioning).
- **feat**: a commit of the type `feat` introduces a new feature to the codebase (this correlates with MINOR in Semantic Versioning).
- **BREAKING CHANGE**: a commit that has a footer `BREAKING CHANGE:`, or appends a `!` after the type/scope, introduces a breaking API change (correlating with MAJOR in Semantic Versioning). A BREAKING CHANGE can be part of commits of any type.

Base configuration used for this project is [commitlint-config-conventional (based on the Angular convention)](https://github.com/conventional-changelog/commitlint/tree/master/@commitlint/config-conventional#type-enum)

## To test the module locally

1. Install all components using the `configure` make target:

```shell
make configure
```

2. Set up Azure authentication. After running `make configure`, an `azure_env.sh` file will be available on your workstation. Modify it to supply the correct values for your environment.

```shell
make env
```

The service principal used for authentication (`ARM_CLIENT_ID`) should have the following privileges on the target subscription:

```
"Microsoft.Insights/autoscalesettings/read"
"Microsoft.Insights/autoscalesettings/write"
"Microsoft.Insights/autoscalesettings/delete"
"Microsoft.Resources/subscriptions/resourceGroups/write"
"Microsoft.Resources/subscriptions/resourceGroups/read"
"Microsoft.Resources/subscriptions/resourceGroups/delete"
"Microsoft.Web/serverfarms/read"
"Microsoft.Web/serverfarms/write"
"Microsoft.Web/serverfarms/delete"
```

3. Run all validation checks:

```shell
make check
```

`make check` runs `terraform lint`, `validate`, and `plan`, plus conftests, OPA policies, and Terratest.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.113 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.117.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_autoscale_setting.autoscale](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_autoscale_setting) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | The name of the AutoScale Setting. Must be unique within the resource group. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the Resource Group in which the AutoScale Setting should exist. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where the AutoScale Setting should be created. | `string` | n/a | yes |
| <a name="input_target_resource_id"></a> [target\_resource\_id](#input\_target\_resource\_id) | The full ARM resource ID of the resource (e.g. App Service Plan, VMSS) that the AutoScale Setting should be applied to. | `string` | n/a | yes |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Specifies whether automatic scaling is enabled for the target resource. Defaults to true. | `bool` | `true` | no |
| <a name="input_profiles"></a> [profiles](#input\_profiles) | One or more profile blocks (up to 20) defining the autoscale behavior.<br/>name     = Name of the profile.<br/>capacity:<br/>  default  = The number of instances to use if metrics are not available. Must be between minimum and maximum.<br/>  maximum  = The maximum number of instances for this resource (0-1000).<br/>  minimum  = The minimum number of instances for this resource (0-1000).<br/>rules = Optional list of scaling rule blocks:<br/>  metric\_trigger:<br/>    metric\_name              = The name of the metric that defines what the rule monitors (e.g. CpuPercentage).<br/>    metric\_resource\_id       = The ID of the resource the metric is collected from. Defaults to target\_resource\_id when null.<br/>    operator                 = The operator used to compare the metric data and the threshold (Equals, NotEquals, GreaterThan, GreaterThanOrEqual, LessThan, LessThanOrEqual).<br/>    statistic                = How metrics from multiple instances are combined (Average, Max, Min, Sum).<br/>    time\_aggregation         = How the metrics are combined over the time\_window (Average, Count, Last, Maximum, Minimum, Total).<br/>    time\_grain               = The granularity of metrics in ISO 8601 duration format (e.g. PT1M).<br/>    time\_window              = The time range over which instance data is collected in ISO 8601 duration format (e.g. PT5M, PT12H).<br/>    threshold                = The threshold of the metric that triggers the scale action.<br/>    metric\_namespace         = (Optional) The namespace of the metric.<br/>    divide\_by\_instance\_count = (Optional) Whether to divide the metric by the number of instances before the comparison.<br/>    dimensions               = (Optional) List of dimension blocks for filtering metrics:<br/>      name     = Name of the dimension.<br/>      operator = Operator for filtering (Equals, NotEquals).<br/>      values   = List of dimension values to filter on.<br/>  scale\_action:<br/>    cooldown  = Amount of time to wait since the last scaling action in ISO 8601 duration format (PT1M to PT1W).<br/>    direction = Whether to scale Increase or Decrease.<br/>    type      = The type of action (ChangeCount, ExactCount, PercentChangeCount, ServiceAllowedNextValue).<br/>    value     = The number of instances involved in the scaling action.<br/>fixed\_date = (Optional) Specific date/time window for this profile:<br/>  end      = End time in RFC3339 format.<br/>  start    = Start time in RFC3339 format.<br/>  timezone = (Optional) Timezone, defaults to UTC.<br/>recurrence = (Optional) Recurrence configuration for this profile:<br/>  timezone  = (Optional) Timezone, defaults to UTC.<br/>  days      = List of days the profile is active.<br/>  hours     = List of hours the profile is active.<br/>  minutes   = List of minutes the profile is active. | <pre>list(object({<br/>    name = string<br/>    capacity = object({<br/>      default = number<br/>      maximum = number<br/>      minimum = number<br/>    })<br/>    rules = optional(list(object({<br/>      metric_trigger = object({<br/>        metric_name              = string<br/>        metric_resource_id       = optional(string)<br/>        operator                 = string<br/>        statistic                = string<br/>        time_aggregation         = string<br/>        time_grain               = string<br/>        time_window              = string<br/>        threshold                = number<br/>        metric_namespace         = optional(string)<br/>        divide_by_instance_count = optional(bool)<br/>        dimensions = optional(list(object({<br/>          name     = string<br/>          operator = string<br/>          values   = list(string)<br/>        })))<br/>      })<br/>      scale_action = object({<br/>        cooldown  = string<br/>        direction = string<br/>        type      = string<br/>        value     = string<br/>      })<br/>    })))<br/>    fixed_date = optional(object({<br/>      end      = string<br/>      start    = string<br/>      timezone = optional(string, "UTC")<br/>    }))<br/>    recurrence = optional(object({<br/>      timezone = optional(string, "UTC")<br/>      days     = list(string)<br/>      hours    = list(number)<br/>      minutes  = list(number)<br/>    }))<br/>  }))</pre> | n/a | yes |
| <a name="input_notification"></a> [notification](#input\_notification) | Optional notification configuration for scale events.<br/>email:<br/>  custom\_emails                         = (Optional) List of custom email addresses to notify.<br/>  send\_to\_subscription\_administrator    = (Optional) Whether to notify the subscription administrator.<br/>  send\_to\_subscription\_co\_administrator = (Optional) Whether to notify co-administrators.<br/>webhook = (Optional) List of webhook blocks:<br/>  service\_uri = The HTTPS URI of the webhook endpoint.<br/>  properties  = (Optional) A map of key/value pairs sent with the webhook. | <pre>object({<br/>    email = optional(object({<br/>      custom_emails                         = optional(list(string))<br/>      send_to_subscription_administrator    = optional(bool, false)<br/>      send_to_subscription_co_administrator = optional(bool, false)<br/>    }))<br/>    webhook = optional(list(object({<br/>      service_uri = string<br/>      properties  = optional(map(string))<br/>    })))<br/>  })</pre> | `null` | no |
| <a name="input_predictive"></a> [predictive](#input\_predictive) | Optional predictive autoscale configuration. Set to null (the default) to disable predictive autoscale.<br/>NOTE: Predictive autoscale is only supported for Virtual Machine Scale Sets. Setting this for other<br/>resource types (e.g. App Service Plans) will result in a 400 error from the Azure API.<br/>scale\_mode      = The predictive scale mode (Enabled or ForecastOnly).<br/>look\_ahead\_time = (Optional) The amount of time by which instances are launched in advance in ISO 8601 duration format (PT1M to PT1H). | <pre>object({<br/>    scale_mode      = string<br/>    look_ahead_time = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the AutoScale Setting resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the AutoScale Setting. |
| <a name="output_name"></a> [name](#output\_name) | The name of the AutoScale Setting. |
| <a name="output_target_resource_id"></a> [target\_resource\_id](#output\_target\_resource\_id) | The ARM resource ID of the target resource the AutoScale Setting is applied to. |
<!-- END_TF_DOCS -->
