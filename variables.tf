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

variable "name" {
  description = "The name of the AutoScale Setting. Must be unique within the resource group."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the Resource Group in which the AutoScale Setting should exist."
  type        = string
}

variable "location" {
  description = "The Azure region where the AutoScale Setting should be created."
  type        = string
}

variable "target_resource_id" {
  description = "The full ARM resource ID of the resource (e.g. App Service Plan, VMSS) that the AutoScale Setting should be applied to."
  type        = string
}

variable "enabled" {
  description = "Specifies whether automatic scaling is enabled for the target resource. Defaults to true."
  type        = bool
  default     = true
}

variable "profiles" {
  description = <<-EOT
    One or more profile blocks (up to 20) defining the autoscale behavior.
    name     = Name of the profile.
    capacity:
      default  = The number of instances to use if metrics are not available. Must be between minimum and maximum.
      maximum  = The maximum number of instances for this resource (0-1000).
      minimum  = The minimum number of instances for this resource (0-1000).
    rules = Optional list of scaling rule blocks:
      metric_trigger:
        metric_name              = The name of the metric that defines what the rule monitors (e.g. CpuPercentage).
        metric_resource_id       = The ID of the resource the metric is collected from. Defaults to target_resource_id when null.
        operator                 = The operator used to compare the metric data and the threshold (Equals, NotEquals, GreaterThan, GreaterThanOrEqual, LessThan, LessThanOrEqual).
        statistic                = How metrics from multiple instances are combined (Average, Max, Min, Sum).
        time_aggregation         = How the metrics are combined over the time_window (Average, Count, Last, Maximum, Minimum, Total).
        time_grain               = The granularity of metrics in ISO 8601 duration format (e.g. PT1M).
        time_window              = The time range over which instance data is collected in ISO 8601 duration format (e.g. PT5M, PT12H).
        threshold                = The threshold of the metric that triggers the scale action.
        metric_namespace         = (Optional) The namespace of the metric.
        divide_by_instance_count = (Optional) Whether to divide the metric by the number of instances before the comparison.
        dimensions               = (Optional) List of dimension blocks for filtering metrics:
          name     = Name of the dimension.
          operator = Operator for filtering (Equals, NotEquals).
          values   = List of dimension values to filter on.
      scale_action:
        cooldown  = Amount of time to wait since the last scaling action in ISO 8601 duration format (PT1M to PT1W).
        direction = Whether to scale Increase or Decrease.
        type      = The type of action (ChangeCount, ExactCount, PercentChangeCount, ServiceAllowedNextValue).
        value     = The number of instances involved in the scaling action.
    fixed_date = (Optional) Specific date/time window for this profile:
      end      = End time in RFC3339 format.
      start    = Start time in RFC3339 format.
      timezone = (Optional) Timezone, defaults to UTC.
    recurrence = (Optional) Recurrence configuration for this profile:
      timezone  = (Optional) Timezone, defaults to UTC.
      days      = List of days the profile is active.
      hours     = List of hours the profile is active.
      minutes   = List of minutes the profile is active.
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

  validation {
    condition     = length(var.profiles) >= 1 && length(var.profiles) <= 20
    error_message = "At least one profile is required and a maximum of 20 profiles are allowed."
  }

  validation {
    condition = alltrue([
      for p in var.profiles :
      p.capacity.minimum >= 0 && p.capacity.minimum <= 1000 &&
      p.capacity.maximum >= 0 && p.capacity.maximum <= 1000 &&
      p.capacity.default >= 0 && p.capacity.default <= 1000 &&
      p.capacity.minimum <= p.capacity.default &&
      p.capacity.default <= p.capacity.maximum
    ])
    error_message = "Each profile capacity must satisfy: 0 <= minimum <= default <= maximum <= 1000."
  }

  validation {
    condition = alltrue([
      for p in var.profiles :
      !(p.fixed_date != null && p.recurrence != null)
    ])
    error_message = "A profile may not have both fixed_date and recurrence set simultaneously."
  }

  validation {
    condition = alltrue(flatten([
      for p in var.profiles : [
        for r in coalesce(p.rules, []) :
        contains(["Equals", "NotEquals", "GreaterThan", "GreaterThanOrEqual", "LessThan", "LessThanOrEqual"], r.metric_trigger.operator)
      ]
    ]))
    error_message = "metric_trigger.operator must be one of: Equals, NotEquals, GreaterThan, GreaterThanOrEqual, LessThan, LessThanOrEqual."
  }

  validation {
    condition = alltrue(flatten([
      for p in var.profiles : [
        for r in coalesce(p.rules, []) :
        contains(["Average", "Max", "Min", "Sum"], r.metric_trigger.statistic)
      ]
    ]))
    error_message = "metric_trigger.statistic must be one of: Average, Max, Min, Sum."
  }

  validation {
    condition = alltrue(flatten([
      for p in var.profiles : [
        for r in coalesce(p.rules, []) :
        contains(["Average", "Count", "Last", "Maximum", "Minimum", "Total"], r.metric_trigger.time_aggregation)
      ]
    ]))
    error_message = "metric_trigger.time_aggregation must be one of: Average, Count, Last, Maximum, Minimum, Total."
  }

  validation {
    condition = alltrue(flatten([
      for p in var.profiles : [
        for r in coalesce(p.rules, []) :
        contains(["Increase", "Decrease"], r.scale_action.direction)
      ]
    ]))
    error_message = "scale_action.direction must be one of: Increase, Decrease."
  }

  validation {
    condition = alltrue(flatten([
      for p in var.profiles : [
        for r in coalesce(p.rules, []) :
        contains(["ChangeCount", "ExactCount", "PercentChangeCount", "ServiceAllowedNextValue"], r.scale_action.type)
      ]
    ]))
    error_message = "scale_action.type must be one of: ChangeCount, ExactCount, PercentChangeCount, ServiceAllowedNextValue."
  }
}

variable "notification" {
  description = <<-EOT
    Optional notification configuration for scale events.
    email:
      custom_emails                         = (Optional) List of custom email addresses to notify.
      send_to_subscription_administrator    = (Optional) Whether to notify the subscription administrator.
      send_to_subscription_co_administrator = (Optional) Whether to notify co-administrators.
    webhook = (Optional) List of webhook blocks:
      service_uri = The HTTPS URI of the webhook endpoint.
      properties  = (Optional) A map of key/value pairs sent with the webhook.
  EOT
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
  description = <<-EOT
    Optional predictive autoscale configuration. Set to null (the default) to disable predictive autoscale.
    NOTE: Predictive autoscale is only supported for Virtual Machine Scale Sets. Setting this for other
    resource types (e.g. App Service Plans) will result in a 400 error from the Azure API.
    scale_mode      = The predictive scale mode (Enabled or ForecastOnly).
    look_ahead_time = (Optional) The amount of time by which instances are launched in advance in ISO 8601 duration format (PT1M to PT1H).
  EOT
  type = object({
    scale_mode      = string
    look_ahead_time = optional(string)
  })
  default = null

  validation {
    condition     = var.predictive == null ? true : contains(["Enabled", "ForecastOnly"], var.predictive.scale_mode)
    error_message = "predictive.scale_mode must be one of: Enabled, ForecastOnly. To disable predictive autoscale, set predictive = null."
  }
}

variable "tags" {
  description = "A map of tags to assign to the AutoScale Setting resource."
  type        = map(string)
  default     = {}
}
