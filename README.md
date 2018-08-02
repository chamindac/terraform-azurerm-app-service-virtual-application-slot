# terraform-azurerm-app-service-virtual-application-slot
Terraform module designed to add VirualApplications on an existing Slot on a Azure PaaS Service and Function Apps.

## Usage

### Sample
Include this repository as a module in your existing terraform code:

```hcl
# Get data from existing Service App
data "azurerm_app_service" "test" {
  name                = "testing-app-service"
  resource_group_name = "testing-service-rg"
}

# Create a new slot
resource "azurerm_app_service_slot" "test" {
  name                = "staging"
  app_service_name    = "${data.azurerm_app_service.test.name}"
  location            = "${data.azurerm_app_service.test.location}"
  resource_group_name = "${data.azurerm_app_service.test.resource_group_name}"
  app_service_plan_id = "${data.azurerm_app_service.test.app_service_plan_id}"

  site_config {
    dotnet_framework_version = "v4.0"
  }

  app_settings {
    "SOME_KEY" = "some-value"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=some-server.mydomain.com;Integrated Security=SSPI"
  }

# Add Virual Applications to Services App slot
module "eg_test_slot_add_virtualApplication" {
  source     = "git::https://github.com/transactiveltd/tf-module-azure-arm-service-app-slot-virtual-application.git?ref=v0.1.0"

  service_app_name    = "${data.azurerm_app_service.test.name}"
  slot_name           = "${azurerm_app_service_slot.test.name}"
  application_names   = ["api","coolapp"]
  resource_group_name = "${data.azurerm_app_service.test.resource_group_name}"
}
```

This will run an arm template deployment on the given resource group containing the Service App and add the VirtualApplications to the specified Slot.
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| service_app_name | Service App Name, e.g. `Site01` | string | - | yes |
| slot_name | Slot name eg: `staging` | string | - | yes |
| application_names | List of applications to create VirualApplications <br>eg: `["api","coolapps"]`| list | - | yes |
| resource_group_name | Resource Group name, e.g. `testing-service-rg` | string | - | yes |


## Outputs

| Name | Description |
|------|-------------|
| resource_group_name | Resource Group name |
