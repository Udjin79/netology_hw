variable "instance_names" {
  description = "The names of the instances"
  type        = list(string)
  default     = ["clickhouse", "vector", "lighthouse"]
}

variable "instance_cores" {
  description = "Number of cores for the instance"
  type        = number
  default     = 2
}

variable "instance_memory" {
  description = "Amount of memory for the instance"
  type        = number
  default     = 2
}

variable "instance_core_fraction" {
  description = "Core fraction for the instance"
  type        = number
  default     = 5
}

###cloud vars
variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network&subnet name"
}

variable "metadata" {
  default = {
    "serial-port-enable" = "1"
        ssh-keys = "*********************************************"
  }
}
