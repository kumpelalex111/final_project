resource "yandex_container_registry" "registry-alex-netology" {
  name      = "registry-alex-netology"
  folder_id = var.folder_id

  labels = {
    environment = "production"
  }
}

output "registry_id" {
  value       = yandex_container_registry.registry-alex-netology.id
  description = "ID созданного Container Registry"
}