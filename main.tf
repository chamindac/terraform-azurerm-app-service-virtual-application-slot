resource "azurerm_template_deployment" "service_app_slot_virtual_application_main" {
  name                = "${format("%s-arm-virtual-directories", var.webapp_name)}"
  resource_group_name = "${var.resource_group_name}"
  deployment_mode     = "Incremental"

  template_body = <<DEPLOY
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "appServiceName": {
      "type": "string"
    },
    "slotName":{
      "type": "string"
    },
    "applicationNames":{
      "type": "string"
    }
  },
  "variables": {
      "applicationNames" :"[split(parameters('applicationNames'),',')]",
      "child": {
        "copy": [
            {
                "name": "applications",
                "count": "[length(variables('applicationNames'))]",
                "input": {
                    "virtualPath": "[concat('/', variables('applicationNames')[copyIndex('applications')]) ]",
                    "physicalPath": "[concat('site\\wwwroot\\', variables('applicationNames')[copyIndex('applications')]) ]",
                    "preloadEnabled": false,
                    "virtualDirectories": null
                }
            }
        ]
        },
        "root":[
            {
                "virtualPath": "/",
                "physicalPath": "site\\wwwroot",
                "preloadEnabled": false,
                "virtualDirectories": null
            }
        ],
        "virtualApplications":"[union(variables('child').applications, variables('root'))]"
  },
  "resources": [
    {
      "comments": "WebApp VirtualDirectories",
      "type": "Microsoft.Web/sites/slots/config",
      "name": [concat(parameters('appServiceName'),'/',parameters('slotName') ,'/web')]",
      "apiVersion": "2016-08-01",
      "properties": {
        "virtualApplications": "[variables('virtualApplications')]"
        },
      "dependsOn": []
    }
  ]
}
DEPLOY

  parameters {
    "appServiceName"   = "${var.app_service_name}"
    "applicationNames" = "${join(",",var.application_names)}"
    "slotName"         = "${var.slot_name}"
  }

  depends_on = []
}
