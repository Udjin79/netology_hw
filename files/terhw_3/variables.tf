### cloud variables
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
        ssh-keys = "ubuntu:ssh-ed25519 ********************************"
  }
}

### Basic variables

variable "image_id" {
  description = "ID образа для использования на VM"
  type        = string
  default     = "fd870suu28d40fqp8srr"
}

variable "ssh_key_path" {
  description = "Путь к открытому ключу SSH"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

### Main and Replica variables

variable "vm_name_main" {
  description = "Имя main VM"
  type        = string
  default     = "main"
}

variable "cpu_main" {
  description = "Количество процессоров для main VM"
  type        = number
  default     = 4
}

variable "ram_main" {
  description = "Объем оперативной памяти для main VM"
  type        = number
  default     = 8
}

variable "disk_volume_main" {
  description = "Размер диска для main VM"
  type        = number
  default     = 50
}

variable "vm_name_replica" {
  description = "Имя replica VM"
  type        = string
  default     = "replica"
}

variable "cpu_replica" {
  description = "Количество процессоров для replica VM"
  type        = number
  default     = 2
}

variable "ram_replica" {
  description = "Объем оперативной памяти для replica VM"
  type        = number
  default     = 4
}

variable "disk_volume_replica" {
  description = "Размер диска для replica VM"
  type        = number
  default     = 20
}

### web VM variables

variable "web_cores" {
  description = "Количество процессоров для web VM"
  type        = number
  default     = 2
}

variable "web_memory" {
  description = "Объем оперативной памяти для web VM в ГБ"
  type        = number
  default     = 2
}

variable "web_disk_size" {
  description = "Размер диска для web VM в ГБ"
  type        = number
  default     = 20
}

### Resource variables

variable "storage_disk_size" {
  description = "Размер дисков в ГБ"
  type        = number
  default     = 1
}

variable "storage_cores" {
  description = "Количество процессоров для инстанса storage"
  type        = number
  default     = 2
}

variable "storage_memory" {
  description = "Объем оперативной памяти для инстанса storage в ГБ"
  type        = number
  default     = 1
}

variable "storage_core_fraction" {
  description = "Доля процессорного времени для инстанса storage"
  type        = number
  default     = 5
}

variable "storage_image_id" {
  description = "ID образа для использования на инстансе storage"
  type        = string
  default     = "fd8g64rcu9fq5kpfqls0"
}
