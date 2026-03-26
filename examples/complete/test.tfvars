product_family     = "dso"
product_service    = "mon"
environment        = "dev"
environment_number = 0
resource_number    = 0
location           = "eastus"

app_service_plan_os_type  = "Linux"
app_service_plan_sku_name = "S1"

enabled = true

profiles = [
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

tags = {
  env = "dev"
}

notification = {
  email = {
    custom_emails                         = ["test@example.com"]
    send_to_subscription_administrator    = false
    send_to_subscription_co_administrator = false
  }
}
