resource "azurerm_subnet" "myterraformsubnet" {
    name                 = "mySubnet"
    resource_group_name  = azurerm_resource_group.ans.name
    virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
    address_prefix       = "10.0.2.0/24"
}
resource "azurerm_public_ip" "myterraformpublicip" {
    name                         = "myPublicIP"
    location                     = "CENTRAL us"
    resource_group_name          = azurerm_resource_group.ans.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "Dev"
    }
}
resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "myNetworkSecurityGroup"
    location            = "Central Us"
    resource_group_name = azurerm_resource_group.ans.name
    
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "Dev"
    }
}
resource "azurerm_network_interface" "myterraformnic" {
    name                      = "myNIC"
    location                  = "Central US"
    resource_group_name       = azurerm_resource_group.ans.name
    network_security_group_id = azurerm_network_security_group.myterraformnsg.id

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = azurerm_subnet.myterraformsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
    }

    tags = {
        environment = "Central Us"
    }
}

resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "tanmaisim"
    resource_group_name         = azurerm_resource_group.ans.name
    location                    = "central us"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "Dev"
    }
}
resource "azurerm_virtual_machine" "myterraformvm" {
    name                  = "myVM"
    location              = "central us"
    resource_group_name   = azurerm_resource_group.ans.name
    network_interface_ids = [azurerm_network_interface.myterraformnic.id]
    vm_size               = "Standard_DS1_v2"

    storage_os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "myvm"
        admin_username = "tanmai"
        admin_password = "Tanmaidonavalli20"
    }

    os_profile_linux_config {
        disable_password_authentication = false
        
    }

    boot_diagnostics {
        enabled = "true"
        storage_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
    }

    tags = {
        environment = "Dev"
    }
}