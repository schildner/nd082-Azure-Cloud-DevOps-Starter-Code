provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "${var.loc_short}-${var.prefix}-rg"
  location = var.location
  tags = {
    project_name = "IaC"
    stage        = "Submission"
  }
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.loc_short}-${var.prefix}-nw"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    project_name = "IaC"
    stage        = "Submission"
  }
}

resource "azurerm_network_security_group" "main" {
  name                = "${var.loc_short}-${var.prefix}-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
    
  security_rule {
    name                       = "AllowOutboundSameSubnetVms"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "DenyInboundInternet"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  tags = {
    project_name = "IaC"
    stage        = "Submission"
  }
}

resource "azurerm_subnet" "main" {
  name                 = "${var.loc_short}-${var.prefix}-subnet1"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "main" {
  name                = "${var.loc_short}-${var.prefix}-nic"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "main"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    project_name = "IaC"
    stage        = "Submission"
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  count                           = var.number_of_vms
  name                            = "${var.loc_short}-${var.prefix}-vm-${count.index}"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = "Standard_D2s_v3"
  admin_username                  = var.username
  admin_password                  = var.password
  source_image_id                 = var.packer_image
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}

resource "azurerm_lb" "main" {
  name                = "${var.loc_short}-${var.prefix}-lb"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.main.id
  }

  tags = {
    project_name = "IaC"
    stage        = "Submission"
  }
}

resource "azurerm_lb_backend_address_pool" "main" {
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.main.id
  name                = "BackEndAddressPool"
}

resource "azurerm_public_ip" "main" {
  name                = "${var.loc_short}-${var.prefix}-ip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"

  tags = {
    project_name = "IaC"
    stage        = "Submission"
  }
}

resource "azurerm_availability_set" "main" {
  name                = "${var.loc_short}-${var.prefix}-as"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  managed             = true

  tags = {
    project_name = "IaC"
    stage        = "Submission"
  }
}

resource "azurerm_managed_disk" "main" {
  name                 = "${var.loc_short}-${var.prefix}-md"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1"

  tags = {
    project_name = "IaC"
    stage        = "Submission"
  }
}