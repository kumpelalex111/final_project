terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.200.0"
    }
  }
  backend "s3" {
    endpoint = "https://storage.yandexcloud.net"
    # Блокировка через YDB
    dynamodb_endpoint = "https://docapi.serverless.yandexcloud.net/ru-central1/b1gqp7736vu8p0hhjd3j/etncs4ijia33plvs4ti6"
    dynamodb_table = "tf-state-locks-table"

    bucket = "tf-state-bucket-alex-06082026"
    region = "ru-central1"
    key    = "prod/terraform.tfstate"
    # Заставляем DNS использовать path-style ссылки
    use_path_style = true
    
    # Отключаем шифрование на стороне клиента (шифрование на стороне бакета)
    encrypt        = false
   
    # Параметры совместимости AWS (для Yandex Cloud обязательны true)
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    
  }

}

provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  #zone      = "ru-central1-b"
  service_account_key_file = file("~/.key/k8s-sa_key.json")
} 
