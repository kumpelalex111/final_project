# Создание базы данных YDB (Serverless)
resource "yandex_ydb_database_serverless" "tf-state-locks-ydb" {
  name = "tf-state-locks-ydb"
}

data "yandex_lockbox_secret_version" "key_for_k8s_sa" {
  secret_id = "e6qbcdnjud9i8a51a333" # Замените на реальный ID из Lockbox
}


# Настраиваем AWS провайдер на Document API эндпоинт созданной YDB
provider "aws" {
  region                      = "ru-central1" # Для Yandex Cloud всегда указывается этот регион
  access_key = { for entry in data.yandex_lockbox_secret_version.key_for_k8s_sa.entries : entry.key => entry.text_value }["access_key"]
  secret_key = { for entry in data.yandex_lockbox_secret_version.key_for_k8s_sa.entries : entry.key => entry.text_value }["secret_key"]

  # access_key                  = data.yandex_lockbox_secret_version.key_for_k8s_sa.entries["access_key"]
  # secret_key                  = data.yandex_lockbox_secret_version.key_for_k8s_sa.entries["secret_key"]
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_requesting_account_id  = true

  # перенаправляем запросы в Yandex Cloud Document API
  endpoints {
    dynamodb = yandex_ydb_database_serverless.tf-state-locks-ydb.document_api_endpoint
  }
}

resource "time_sleep" "wait_for_ydb" {
 depends_on = [yandex_ydb_database_serverless.tf-state-locks-ydb]

 create_duration = "10s"
}
# Создаем таблицу
resource "aws_dynamodb_table" "tf-state-locks-table" {
  name         = "tf-state-locks-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"           
  depends_on = [time_sleep.wait_for_ydb]
  attribute {
    name = "LockID"
    type = "S"                      
  }
}


output "ydb_document_api_endpoint" {
  value = yandex_ydb_database_serverless.tf-state-locks-ydb.document_api_endpoint
}
