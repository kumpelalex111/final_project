
variable "cloud_id" {
  type     = string
  default  = "b1gqp7736vu8p0hhjd3"
}

variable "folder_id" {
  type     = string
  default  = "b1g1l3kvci39gedjn74j"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = ""
}
variable "backup_zone" {
  type        = string
  default     = "ru-central1-b"
  description = ""
}

variable "backup_zone1" {
  type        = string
  default     = "ru-central1-e"
  description = ""
}

variable "public_cidr" {
  type        = list(string)
  default     = ["192.168.10.0/24"]
  
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network&subnet name"
}

variable "bastion_cidr" {
  type        = list(string)
  default     = ["192.168.40.0/24"]
}

variable "k8s-1_cidr" {
  type        = list(string)
  default     = ["192.168.50.0/24"]  
}

variable "k8s-2_cidr" {
  type        = list(string)
  default     = ["192.168.60.0/24"]  
}

variable "k8s-3_cidr" {
  type        = list(string)
  default     = ["192.168.70.0/24"]  
}

variable "service_account_id_k8s" {
  type        = string
  default     = "aje2kajdvm1psj6k1gu2"
}

variable "ip_k8s_master" {
  type        = string
  default     = "192.168.50.5"
}

variable "ip_k8s_worker-1" {
  type        = string
  default     = "192.168.50.21"
}
variable "ip_k8s_worker-2" {
  type        = string
  default     = "192.168.60.22"
}

variable "ip_gitlab" {
  type        = string
  default     = "192.168.50.17"
}

variable "grafana_nodeport" {
  type        = number
  default     = 30001
}
variable "app_nodeport" {
  type        = number
  default     = 30002
}
