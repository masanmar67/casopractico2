#Creación del grupo de recursos
resource "azurerm_resource_group" "rg" {
  name     = "casopractico2RGcr"
  location = var.resource_group_location
}

#Creación del azure container registry
resource "azurerm_container_registry" "cp2cr" {
  name                = "casoPractico2registry"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.resource_group_location
  sku                 = "Standard"
  #Permite obtener las imágenes de manera anónima
  anonymous_pull_enabled = true
}

# Utilizado para indicar que el token solo es cuando se desea hacer push de una imágen
resource "azurerm_container_registry_scope_map" "push_scope" {
  name                  = "push-scope"
  resource_group_name     = azurerm_resource_group.rg.name
  container_registry_name = azurerm_container_registry.cp2cr.name

  actions = [
    for repo in var.acr_repositorios : "repositories/${repo}/content/write"
  ]
}

# El nombre que se le da al token, y será utilizado por podman como nombre de usuario
resource "azurerm_container_registry_token" "push_token" {
  name                  = "tokencasopractico2"
  resource_group_name     = azurerm_resource_group.rg.name
  container_registry_name = azurerm_container_registry.cp2cr.name
  scope_map_id          = azurerm_container_registry_scope_map.push_scope.id
}

# token generado
resource "azurerm_container_registry_token_password" "push_password" {
  container_registry_token_id = azurerm_container_registry_token.push_token.id
  #Azure permite dos contraseñas por token, aqui se indica que utilize la primera para este token
  password1 {
    expiry = "2026-01-01T10:00:00+08:00"
  }
}
