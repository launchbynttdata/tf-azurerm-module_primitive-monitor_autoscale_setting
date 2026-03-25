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

resource "azurerm_monitor_autoscale_setting" "autoscale" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  target_resource_id  = var.target_resource_id
  enabled             = var.enabled

  dynamic "profile" {
    for_each = var.profiles
    content {
      name = profile.value.name

      capacity {
        default = profile.value.capacity.default
        maximum = profile.value.capacity.maximum
        minimum = profile.value.capacity.minimum
      }

      dynamic "rule" {
        for_each = profile.value.rules != null ? profile.value.rules : []
        content {
          metric_trigger {
            metric_name              = rule.value.metric_trigger.metric_name
            metric_resource_id       = rule.value.metric_trigger.metric_resource_id
            operator                 = rule.value.metric_trigger.operator
            statistic                = rule.value.metric_trigger.statistic
            time_aggregation         = rule.value.metric_trigger.time_aggregation
            time_grain               = rule.value.metric_trigger.time_grain
            time_window              = rule.value.metric_trigger.time_window
            threshold                = rule.value.metric_trigger.threshold
            metric_namespace         = rule.value.metric_trigger.metric_namespace
            divide_by_instance_count = rule.value.metric_trigger.divide_by_instance_count

            dynamic "dimensions" {
              for_each = rule.value.metric_trigger.dimensions != null ? rule.value.metric_trigger.dimensions : []
              content {
                name     = dimensions.value.name
                operator = dimensions.value.operator
                values   = dimensions.value.values
              }
            }
          }

          scale_action {
            cooldown  = rule.value.scale_action.cooldown
            direction = rule.value.scale_action.direction
            type      = rule.value.scale_action.type
            value     = rule.value.scale_action.value
          }
        }
      }

      dynamic "fixed_date" {
        for_each = profile.value.fixed_date != null ? [profile.value.fixed_date] : []
        content {
          end      = fixed_date.value.end
          start    = fixed_date.value.start
          timezone = fixed_date.value.timezone
        }
      }

      dynamic "recurrence" {
        for_each = profile.value.recurrence != null ? [profile.value.recurrence] : []
        content {
          timezone = recurrence.value.timezone
          days     = recurrence.value.days
          hours    = recurrence.value.hours
          minutes  = recurrence.value.minutes
        }
      }
    }
  }

  dynamic "notification" {
    for_each = var.notification != null ? [var.notification] : []
    content {
      dynamic "email" {
        for_each = notification.value.email != null ? [notification.value.email] : []
        content {
          custom_emails                         = email.value.custom_emails
          send_to_subscription_administrator    = email.value.send_to_subscription_administrator
          send_to_subscription_co_administrator = email.value.send_to_subscription_co_administrator
        }
      }

      dynamic "webhook" {
        for_each = notification.value.webhook != null ? notification.value.webhook : []
        content {
          service_uri = webhook.value.service_uri
          properties  = webhook.value.properties
        }
      }
    }
  }

  dynamic "predictive" {
    for_each = var.predictive != null ? [var.predictive] : []
    content {
      scale_mode      = predictive.value.scale_mode
      look_ahead_time = predictive.value.look_ahead_time
    }
  }

  tags = var.tags
}
