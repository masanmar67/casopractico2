resource "azurerm_resource_group" "rg" {
  name = "casopractico2RGvm"
  location = "eastus"
}

#Esta regal de seguridad permite entrada de peticiones por el puerto 22 y el 8080
#El primero es para poder usar ssh para conectarse a la máquina virtual
#El segundo es para poder tener acceso al servidor corriendo en el contenedor
resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "myNetworkSecurityGroup"
    location            = "eastus"
    resource_group_name = azurerm_resource_group.rg.name

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

    security_rule {
        name                       = "HTTP_8080"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8080"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "Terraform Demo"
    }
}

#Red virtual necesaria para alojar la máquina virtual
resource "azurerm_virtual_network" "myvnet" {
  name   =   "my-vnet"
  address_space   =   [ "10.0.0.0/24" ]
  location   =   "eastus"
  resource_group_name   =   azurerm_resource_group.rg.name
}

#La subred donde la máquina virtual obtendrá la ip asignada
resource   "azurerm_subnet"   "frontendsubnet"   {
  name   =   "frontendsubnet"
  resource_group_name   =    azurerm_resource_group.rg.name
  virtual_network_name   =   azurerm_virtual_network.myvnet.name
  address_prefixes   =  ["10.0.0.64/26"]
}

#Recurso usado para obtener una ip publica, que será asociada a la red virtual por medio de la interface definida
resource   "azurerm_public_ip"   "azurevm1publicip"   {
  name   =   "pip1"
  location   =   "eastus"
  resource_group_name   =   azurerm_resource_group.rg.name
  allocation_method   =   "Static"
  sku   =   "Standard"
}

#Definición de la interface de red utilizada por la máquina virtual
resource "azurerm_network_interface" "azurevm1nic"   {
  name   =   "azurevm1-nic"
  location   =   "eastus"
  resource_group_name   =   azurerm_resource_group.rg.name

  ip_configuration   {
    name   =   "ipconfig1"
    subnet_id   =   azurerm_subnet.frontendsubnet.id
    private_ip_address_allocation   =   "Dynamic"
    public_ip_address_id   =   azurerm_public_ip.azurevm1publicip.id
  }
}

#Asociación de la interface de red con el grupo de seguridad
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.azurevm1nic.id
  network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}

resource "azurerm_linux_virtual_machine" "myterraformvm"   {
  name                    =   "azurevm1"
  location                =   "eastus"
  resource_group_name     =   azurerm_resource_group.rg.name
  network_interface_ids   =   [ azurerm_network_interface.azurevm1nic.id ]
  size                    =   "Standard_B1s"
  computer_name           =   "linuxvm"
  admin_username          =   "ubuntu"

  #Uso del par de llaves creadas para iniciar sesión en la máquina virtual
  admin_ssh_key {
    username   = "ubuntu"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk   {
    caching             =   "ReadWrite"
    storage_account_type   = "Standard_LRS"
  }
}

