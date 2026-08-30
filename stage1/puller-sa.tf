resource "yandex_iam_service_account" "image-puller-new" {
  name        = "image-puller-new"
  description = "Service account for pulling images from Container Registry"
}

resource "yandex_resourcemanager_folder_iam_member" "puller_folder" {
  folder_id = var.folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.image-puller-new.id}"
}

resource "yandex_iam_service_account_key" "puller-json-key" {
  service_account_id = yandex_iam_service_account.image-puller-new.id
  description        = "JSON key for Kubernetes image pulling"
}

resource "local_file" "k8s-sa-key-file" {
    content = yandex_iam_service_account_key.puller-json-key.private_key
    filename = "/home/alex/.key/image-puller-new-sa-key.json"
    file_permission = "0600"
}

