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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.113 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_autoscale_setting.autoscale](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_autoscale_setting) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Specifies whether automatic scaling is enabled for the target resource. Defaults to true. | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where the AutoScale Setting should be created. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the AutoScale Setting. Must be unique within the resource group. | `string` | n/a | yes |
| <a name="input_notification"></a> [notification](#input\_notification) | Optional notification configuration for scale events.<br/>email:<br/>  custom\_emails                         = (Optional) List of custom email addresses to notify.<br/>  send\_to\_subscription\_administrator    = (Optional) Whether to notify the subscription administrator.<br/>  send\_to\_subscription\_co\_administrator = (Optional) Whether to notify co-administrators.<br/>webhook = (Optional) List of webhook blocks:<br/>  service\_uri = The HTTPS URI of the webhook endpoint.<br/>  properties  = (Optional) A map of key/value pairs sent with the webhook. | <pre>object({<br/>    email = optional(object({<br/>      custom_emails                         = optional(list(string))<br/>      send_to_subscription_administrator    = optional(bool, false)<br/>      send_to_subscription_co_administrator = optional(bool, false)<br/>    }))<br/>    webhook = optional(list(object({<br/>      service_uri = string<br/>      properties  = optional(map(string))<br/>    })))<br/>  })</pre> | `null` | no |
| <a name="input_predictive"></a> [predictive](#input\_predictive) | Optional predictive autoscale configuration. Set to null (the default) to disable predictive autoscale.<br/>NOTE: Predictive autoscale is only supported for Virtual Machine Scale Sets. Setting this for other<br/>resource types (e.g. App Service Plans) will result in a 400 error from the Azure API.<br/>scale\_mode      = The predictive scale mode (Enabled or ForecastOnly).<br/>look\_ahead\_time = (Optional) The amount of time by which instances are launched in advance in ISO 8601 duration format (PT1M to PT1H). | <pre>object({<br/>    scale_mode      = string<br/>    look_ahead_time = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_profiles"></a> [profiles](#input\_profiles) | One or more profile blocks (up to 20) defining the autoscale behavior.<br/>name     = Name of the profile.<br/>capacity:<br/>  default  = The number of instances to use if metrics are not available. Must be between minimum and maximum.<br/>  maximum  = The maximum number of instances for this resource (0-1000).<br/>  minimum  = The minimum number of instances for this resource (0-1000).<br/>rules = Optional list of scaling rule blocks:<br/>  metric\_trigger:<br/>    metric\_name              = The name of the metric that defines what the rule monitors (e.g. CpuPercentage).<br/>    metric\_resource\_id       = The ID of the resource the metric is collected from. Defaults to target\_resource\_id when null.<br/>    operator                 = The operator used to compare the metric data and the threshold (Equals, NotEquals, GreaterThan, GreaterThanOrEqual, LessThan, LessThanOrEqual).<br/>    statistic                = How metrics from multiple instances are combined (Average, Max, Min, Sum).<br/>    time\_aggregation         = How the metrics are combined over the time\_window (Average, Count, Last, Maximum, Minimum, Total).<br/>    time\_grain               = The granularity of metrics in ISO 8601 duration format (e.g. PT1M).<br/>    time\_window              = The time range over which instance data is collected in ISO 8601 duration format (e.g. PT5M, PT12H).<br/>    threshold                = The threshold of the metric that triggers the scale action.<br/>    metric\_namespace         = (Optional) The namespace of the metric.<br/>    divide\_by\_instance\_count = (Optional) Whether to divide the metric by the number of instances before the comparison.<br/>    dimensions               = (Optional) List of dimension blocks for filtering metrics:<br/>      name     = Name of the dimension.<br/>      operator = Operator for filtering (Equals, NotEquals).<br/>      values   = List of dimension values to filter on.<br/>  scale\_action:<br/>    cooldown  = Amount of time to wait since the last scaling action in ISO 8601 duration format (PT1M to PT1W).<br/>    direction = Whether to scale Increase or Decrease.<br/>    type      = The type of action (ChangeCount, ExactCount, PercentChangeCount, ServiceAllowedNextValue).<br/>    value     = The number of instances involved in the scaling action.<br/>fixed\_date = (Optional) Specific date/time window for this profile:<br/>  end      = End time in RFC3339 format.<br/>  start    = Start time in RFC3339 format.<br/>  timezone = (Optional) Timezone, defaults to UTC.<br/>recurrence = (Optional) Recurrence configuration for this profile:<br/>  timezone  = (Optional) Timezone, defaults to UTC.<br/>  days      = List of days the profile is active.<br/>  hours     = List of hours the profile is active.<br/>  minutes   = List of minutes the profile is active. | <pre>list(object({<br/>    name = string<br/>    capacity = object({<br/>      default = number<br/>      maximum = number<br/>      minimum = number<br/>    })<br/>    rules = optional(list(object({<br/>      metric_trigger = object({<br/>        metric_name              = string<br/>        metric_resource_id       = optional(string)<br/>        operator                 = string<br/>        statistic                = string<br/>        time_aggregation         = string<br/>        time_grain               = string<br/>        time_window              = string<br/>        threshold                = number<br/>        metric_namespace         = optional(string)<br/>        divide_by_instance_count = optional(bool)<br/>        dimensions = optional(list(object({<br/>          name     = string<br/>          operator = string<br/>          values   = list(string)<br/>        })))<br/>      })<br/>      scale_action = object({<br/>        cooldown  = string<br/>        direction = string<br/>        type      = string<br/>        value     = string<br/>      })<br/>    })))<br/>    fixed_date = optional(object({<br/>      end      = string<br/>      start    = string<br/>      timezone = optional(string, "UTC")<br/>    }))<br/>    recurrence = optional(object({<br/>      timezone = optional(string, "UTC")<br/>      days     = list(string)<br/>      hours    = list(number)<br/>      minutes  = list(number)<br/>    }))<br/>  }))</pre> | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the Resource Group in which the AutoScale Setting should exist. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the AutoScale Setting resource. | `map(string)` | `{}` | no |
| <a name="input_target_resource_id"></a> [target\_resource\_id](#input\_target\_resource\_id) | The full ARM resource ID of the resource (e.g. App Service Plan, VMSS) that the AutoScale Setting should be applied to. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the AutoScale Setting. |
| <a name="output_name"></a> [name](#output\_name) | The name of the AutoScale Setting. |
| <a name="output_target_resource_id"></a> [target\_resource\_id](#output\_target\_resource\_id) | The ARM resource ID of the target resource the AutoScale Setting is applied to. |
<!-- END_TF_DOCS -->

## Module Development

### Pre-Requisites

The following commands should be available on your system:

- `asdf` or `mise`
- `make`
- `python3` (for pre-commit)

Additionally, your `git` user and email must be configured. Run the `make configure` command from the root of the repository to ensure that you meet these requirements.

### Pre-Commit hooks

The [.pre-commit-config.yaml](.pre-commit-config.yaml) file defines certain `pre-commit` hooks that are relevant to Terraform and Golang, as well as some common linting tasks. These will be configured for you when you run `make configure`.

### Local Validation

You should validate the changes you make to any module locally, prior to pushing your changes in a branch to GitHub.

1. Ensure that you have run `make configure` successfully.

2. Ensure you are signed into the appropriate cloud provider (e.g. AWS or Azure) for the module under test in your current console session.

3. Run the Terraform and Golang linters with the following command:

```
make lint
```

4. Once you have satisfied the linters, the following command will build example infrastructure in your configured cloud, run the tests, and then tear down the infrastructure it created:

```
make test
```

The pre-commit validations, as well as the `make lint` and `make test` targets, will all be performed in CI. Running these validations locally prior to opening a PR helps ensure a smooth review and merge process.

### Review & Merge Process

Once your change has been tested locally and your branch pushed up, open a new Pull Request for your branch to the default (main) branch of this repository.

The title of your Pull Request will determine the version bump for this change, and the title must be in [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/#specification) format in order to merge. A breaking change will trigger a major version bump, a feature will trigger a minor version bump, and all other types will trigger a patch version bump.

Ensure your CI workflows are passing; seek approval from teammates and address any feedback; seek any explicit approvals required by the CODEOWNERS file. You may merge the PR as soon as all requirements are met, and a new release and tag will be automatically created for you.

### Automatic Updates

The shared configuration and workflow files in this repository are largely managed through the [launch-terraform-skeleton](https://github.com/launchbynttdata/launch-terraform-skeleton) repository. Outside of perhaps the `.gitignore` to account for specific files being generated by certain Terraform modules (e.g. Lambda functions), there should not be much cause to update these files on a per-repo basis, and making changes to them individually is discouraged.

If desired, you can check for and run these updates locally in a branch if you have the `copier` tool installed. Some example commands are included below:

```
# Check for updates, optionally checking prerelease versions
copier check-update [--prereleases]

# Run an update, using default answers if there are any. We use tasks, which requires --trust to be set.
copier update --defaults --trust [--prereleases]

# Recopy from the source, and --overwrite all templated files in the process
copier recopy --defaults --trust --overwrite [--prereleases]
```

Automatic updates will run through a scheduled workflow, and if the post-update tests are successful, the Pull Request created will automatically merge. Conflicts in the update or failures to test may leave a Pull Request outstanding, which needs to be addressed by a Launch Engineer.
