output "subnet_id" {
  description = "The ID of the created subnet"
  value       = yandex_vpc_subnet.subnet.id
}

output "network_id" {
  description = "The ID of the created network"
  value       = yandex_vpc_network.network.id
}
