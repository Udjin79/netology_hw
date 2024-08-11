variable "network_name" {
  description = "The name of the VPC network"
  type        = string
}

variable "subnet_name" {
  description = "The name of the VPC subnet"
  type        = string
}

variable "zone" {
  description = "The availability zone where the subnet will be created"
  type        = string
}

variable "v4_cidr_blocks" {
  description = "IPv4 CIDR blocks for the subnet"
  type        = list(string)
}
