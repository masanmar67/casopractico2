output "container_registry_name" {
  value = azurerm_container_registry.cp2cr.name
}

output "container_registry_login_server" {
  value = azurerm_container_registry.cp2cr.login_server
}

output "acr_token_username" {
  value = azurerm_container_registry_token.push_token.name
}

output "acr_token_password" {
  value     = azurerm_container_registry_token_password.push_password.password1[0].value
  sensitive = true
}
