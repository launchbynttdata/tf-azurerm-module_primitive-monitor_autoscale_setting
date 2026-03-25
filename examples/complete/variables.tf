// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

variable "product_family" {
  description = <<-EOT
    (Required) Name of the product family for which the resource is created.
    Example: org_name, department_name.
  EOT
  type        = string
  default     = "dso"
}

variable "product_service" {
  description = <<-EOT
    (Required) Name of the product service for which the resource is created.
    For example, backend, frontend, middleware etc.
  EOT
  type        = string
  default     = "mon"
}

variable "environment" {
  description = "Environment in which the resource should be provisioned like dev, qa, prod etc."
  type        = string
  default     = "dev"
}

variable "environment_number" {
  description = "The environment count for the respective environment. Defaults to 000. Increments in value of 1."
  type        = string
  default     = "000"
}

variable "resource_number" {
  description = "The resource count for the respective resource. Defaults to 000. Increments in value of 1."
  type        = string
  default     = "000"
}

variable "location" {
  description = "Azure region where the resources will be created."
  type        = string
  default     = "eastus"
}

variable "use_azure_region_abbr" {
  description = "Whether to use Azure region abbreviations in resource names (e.g. eus for eastus)."
  type        = bool
  default     = true
}

variable "resource_names_map" {
  description = "A map of key to resource_name that will be used by tf-launch-module_library-resource_name to generate resource names."
  type = map(object({
    name       = string
    max_length = optional(number, 60)
  }))
  default = {
    resource_group = {
      name       = "rg"
      max_length = 80
    }
    app_service_plan = {
      name       = "asp"
      max_length = 40
    }
    monitor_autoscale_setting = {
      name       = "mas"
      max_length = 260
    }
  }
}

# App Service Plan settings

variable "app_service_plan_os_type" {
  description = "The O/S type for the App Service Plan (Linux or Windows)."
  type        = string
  default     = "Linux"
}

variable "app_service_plan_sku_name" {
  description = "The SKU for the App Service Plan (must be a scalable SKU such as S1, S2, P1v2 etc.)."
  type        = string
  default     = "S1"
}

# AutoScale Setting settings

variable "enabled" {
  description = "Specifies whether automatic scaling is enabled for the target resource."
  type        = bool
  default     = true
}

variable "profiles" {
  description = <<-EOT
    One or more profile blocks (up to 20) defining the autoscale behavior. metric_resource_id
    within rules defaults to the App Service Plan ID when not explicitly set.
  EOT
  type = list(object({
    name = string
    capacity = object({
      default = number
      maximum = number
      minimum = number
    })
    rules = optional(list(object({
      metric_trigger = object({
        metric_name              = string
        metric_resource_id       = optional(string)
        operator                 = string
        statistic                = string
        time_aggregation         = string
        time_grain               = string
        time_window              = string
        threshold                = number
        metric_namespace         = optional(string)
        divide_by_instance_count = optional(bool)
        dimensions = optional(list(object({
          name     = string
          operator = string
          values   = list(string)
        })))
      })
      scale_action = object({
        cooldown  = string
        direction = string
        type      = string
        value     = string
      })
    })))
    fixed_date = optional(object({
      end      = string
      start    = string
      timezone = optional(string, "UTC")
    }))
    recurrence = optional(object({
      timezone = optional(string, "UTC")
      days     = list(string)
      hours    = list(number)
      minutes  = list(number)
    }))
  }))
  default = [
    {
      name = "defaultProfile"
      capacity = {
        default = 1
        maximum = 3
        minimum = 1
      }
      rules = [
        {
          metric_trigger = {
            metric_name      = "CpuPercentage"
            operator         = "GreaterThan"
            statistic        = "Average"
            time_aggregation = "Average"
            time_grain       = "PT1M"
            time_window      = "PT5M"
            threshold        = 70
          }
          scale_action = {
            cooldown  = "PT5M"
            direction = "Increase"
            type      = "ChangeCount"
            value     = "1"
          }
        },
        {
          metric_trigger = {
            metric_name      = "CpuPercentage"
            operator         = "LessThan"
            statistic        = "Average"
            time_aggregation = "Average"
            time_grain       = "PT1M"
            time_window      = "PT5M"
            threshold        = 25
          }
          scale_action = {
            cooldown  = "PT5M"
            direction = "Decrease"
            type      = "ChangeCount"
            value     = "1"
          }
        }
      ]
    }
  ]
}

variable "notification" {
  description = "Optional notification configuration for scale events."
  type = object({
    email = optional(object({
      custom_emails                         = optional(list(string))
      send_to_subscription_administrator    = optional(bool, false)
      send_to_subscription_co_administrator = optional(bool, false)
    }))
    webhook = optional(list(object({
      service_uri = string
      properties  = optional(map(string))
    })))
  })
  default = null
}

variable "predictive" {
  description = "Optional predictive autoscale configuration."
  type = object({
    scale_mode      = string
    look_ahead_time = optional(string)
  })
  default = null
}

variable "tags" {
  description = "A map of tags to assign to all resources."
  type        = map(string)
  default     = {}
}
