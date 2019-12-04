resource "azurerm_resource_group" "ans" {
    name     = "TanmaiPlayground"
    location = "Central US"

    tags = {
        environment = "Dev"
    }
}