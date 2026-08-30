resource "yandex_iam_service_account" "k8s-sa" {
  name        = "k8s-sa"
  description = "Service account for regional K8s cluster and node group"
}
# создаем ключ для k8s
resource "yandex_iam_service_account_key" "k8s-sa_key" {
  service_account_id = yandex_iam_service_account.k8s-sa.id
}
resource "local_file" "k8s-sa-key-file" {
    content = yandex_iam_service_account_key.k8s-sa_key.private_key
    filename = "/home/alex/diplom/k8s-sa_key.json"
    file_permission = "0600"
}

# Генерируем реальный статический ключ доступа (AWS-совместимый)
resource "yandex_iam_service_account_static_access_key" "k8s-sa-key-ydb" {
  service_account_id = yandex_iam_service_account.k8s-sa.id
}

# Добавление ролей
# Роль для управления кластером
resource "yandex_resourcemanager_folder_iam_member" "k8s_agent" {
  folder_id = var.folder_id
  role      = "k8s.clusters.agent"
  member    = "serviceAccount:${yandex_iam_service_account.k8s-sa.id}"
}

# Роль для создания балансировщиков и управления публичными IP
resource "yandex_resourcemanager_folder_iam_member" "vpc_public" {
  folder_id = var.folder_id
  role      = "vpc.publicAdmin"
  member    = "serviceAccount:${yandex_iam_service_account.k8s-sa.id}"
}

# Роль для загрузки Docker-образов 
resource "yandex_resourcemanager_folder_iam_member" "images_puller" {
  folder_id   = var.folder_id
  role        = "container-registry.images.puller"
  member      = "serviceAccount:${yandex_iam_service_account.k8s-sa.id}"
}

# Роль для использования ключа шифрования KMS
resource "yandex_resourcemanager_folder_iam_member" "kms_viewer" {
  folder_id = var.folder_id
  role      = "kms.viewer"
  member    = "serviceAccount:${yandex_iam_service_account.k8s-sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s_editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.k8s-sa.id}"
}

resource "yandex_storage_bucket_iam_binding" "bucket_editor" {
  bucket = yandex_storage_bucket.tf-state-bucket-alex-06082026.id
  role   = "storage.editor"
  members = ["serviceAccount:${yandex_iam_service_account.k8s-sa.id}"]
  
}

resource "yandex_resourcemanager_folder_iam_member" "ydb_editor" {
  folder_id = var.folder_id
  role      = "ydb.editor"
  member    = "serviceAccount:${yandex_iam_service_account.k8s-sa.id}"
}

# Назначение роли для push и pull образов
resource "yandex_resourcemanager_folder_iam_member" "registry_pusher" {
  folder_id = var.folder_id
  role      = "container-registry.images.pusher"
  member    = "serviceAccount:${yandex_iam_service_account.k8s-sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "lockbox_viewer" {
  folder_id = var.folder_id
  role      = "lockbox.payloadViewer"
  member    = "serviceAccount:${yandex_iam_service_account.k8s-sa.id}"
}
