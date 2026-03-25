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
- Predictive autoscale (Disabled / Enabled / ForecastOnly)

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

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|--------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.113 |

## Providers

| Name | Version |
|------|--------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.113 |

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
| <a name="input_target_resource_id"></a> [target\_resource\_id](#input\_target\_resource\_id) | The full ARM resource ID of the resource that the AutoScale Setting should be applied to. | `string` | n/a | yes |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Specifies whether automatic scaling is enabled for the target resource. | `bool` | `true` | no |
| <a name="input_profiles"></a> [profiles](#input\_profiles) | One or more profile blocks (up to 20) defining the autoscale behavior. | `list(object({...}))` | n/a | yes |
| <a name="input_notification"></a> [notification](#input\_notification) | Optional notification configuration for scale events. | `object({...})` | `null` | no |
| <a name="input_predictive"></a> [predictive](#input\_predictive) | Optional predictive autoscale configuration. | `object({...})` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the AutoScale Setting resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the AutoScale Setting. |
| <a name="output_name"></a> [name](#output\_name) | The name of the AutoScale Setting. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


