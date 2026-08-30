# Создание KMS-ключа с ротацией раз в год
resource "yandex_kms_symmetric_key" "s3-bucket-key" {
  name              = "s3-bucket-key"
  description       = "Ключ для шифрования S3 бакета с ротацией каждые 90 дней"
  default_algorithm = "AES_256"
  rotation_period   = "8760h" 
}


# Создание статического ключа доступа для сервисного аккаунта (нужен для создания бакета)
resource "yandex_iam_service_account_static_access_key" "sa_static_key" {
  service_account_id = var.service_account_alex
  description        = "Статический ключ для S3"
}


resource "yandex_storage_bucket" "tf-state-bucket-alex-06082026" {
  bucket        = "tf-state-bucket-alex-06082026"
  max_size      = 104857600
  default_storage_class = "standard"
  access_key = yandex_iam_service_account_static_access_key.sa_static_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa_static_key.secret_key

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.s3-bucket-key.id
        sse_algorithm     = "aws:kms"
      }
    }
  }
  anonymous_access_flags {
    read = false
    list = false
    config_read = false
  }
  # Принудительное удаление всех объектов при удалении бакета
  force_destroy = false

  # Версионирование
  versioning {
    enabled = true
  }

  
  tags = {
    Environment = "production"
    Project     = "backet_alex"
    }

}



# Вывод имени бакета
output "bucket_name" {
  value = yandex_storage_bucket.tf-state-bucket-alex-06082026.bucket
}

output "bucket_domain_name" {
  value = yandex_storage_bucket.tf-state-bucket-alex-06082026.bucket_domain_name
}
