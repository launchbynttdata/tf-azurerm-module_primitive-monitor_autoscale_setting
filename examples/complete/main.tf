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

module "monitor_autoscale_setting" {
  source = "../.."

  name                = module.resource_names["monitor_autoscale_setting"].standard
  resource_group_name = module.resource_group.name
  location            = var.location
  target_resource_id  = azurerm_service_plan.app_service_plan.id
  enabled             = var.enabled
  profiles            = var.profiles
  notification        = var.notification
  predictive          = var.predictive
  tags                = merge(var.tags, { resource_name = module.resource_names["monitor_autoscale_setting"].standard })
}
