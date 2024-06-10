terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

variable "yandex-cloud-token" {
  type        = string
  description = "Input yandex_cloud_token"
}

provider "yandex" {
  token     = var.yandex-cloud-token
  cloud_id  = "************************"
  folder_id = "************************"
  zone      = "ru-central1-a"
}

resource "yandex_vpc_network" "course-netology-network" {
  name = "course-netology-network"
}

resource "yandex_vpc_subnet" "external-netology-subnet-a" {
  name           = "external-netology-subnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.course-netology-network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "internal-netology-subnet-b" {
  name           = "internal-netology-subnet-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.course-netology-network.id
  v4_cidr_blocks = ["192.168.20.0/24"]
}

resource "yandex_compute_instance" "course-vm1" {
  name                      = "course-vm1"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd87e3vsemiab8q1tl0h"
      size     = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.internal-netology-subnet-b.id
    nat       = true
  }

  metadata = {
    user-data = "${file("./meta.yml")}"
  }

  zone = "ru-central1-b"
}

resource "yandex_compute_instance" "course-vm2" {
  name                      = "course-vm2"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd87e3vsemiab8q1tl0h"
      size     = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.internal-netology-subnet-b.id
    nat       = true
  }

  metadata = {
    user-data = "${file("./meta.yml")}"
  }

  zone = "ru-central1-b"
}

resource "yandex_alb_target_group" "course-app-group" {
  name = "course-app-target-group"

  target {
    subnet_id  = yandex_compute_instance.course-vm1.network_interface.0.subnet_id
    ip_address = yandex_compute_instance.course-vm1.network_interface.0.ip_address
  }

  target {
    subnet_id  = yandex_compute_instance.course-vm2.network_interface.0.subnet_id
    ip_address = yandex_compute_instance.course-vm2.network_interface.0.ip_address
  }
}

output "course-app-target-group-id" {
  value = yandex_alb_target_group.course-app-group.id
}

resource "yandex_alb_backend_group" "course-app-backend-group" {
  name       = "course-app-backend-group"
  depends_on = [yandex_alb_target_group.course-app-group]

  session_affinity {
    connection {
      source_ip = true
    }
  }

  http_backend {
    name             = "course-http-backend"
    weight           = 1
    port             = 80
    target_group_ids = [yandex_alb_target_group.course-app-group.id]
    load_balancing_config {
      panic_threshold = 90
    }
    healthcheck {
      timeout             = "10s"
      interval            = "2s"
      healthy_threshold   = 10
      unhealthy_threshold = 15
      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "course-app-http-router" {
  name = "course-app-http-router"
  labels = {
    environment = "dev"
  }
}

resource "yandex_alb_virtual_host" "course-app-virtual-host" {
  name           = "course-app-virtual-host"
  http_router_id = yandex_alb_http_router.course-app-http-router.id
  route {
    name = "course-default-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.course-app-backend-group.id
        timeout          = "60s"
      }
    }
  }
}

resource "yandex_alb_load_balancer" "course-lb-app" {
  name               = "course-load-balancer"
  network_id         = yandex_vpc_network.course-netology-network.id
  security_group_ids = []

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.external-netology-subnet-a.id
    }

    location {
      zone_id   = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.internal-netology-subnet-b.id
    }
  }

  listener {
    name = "listener"

    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [80]
    }

    http {
      handler {
        http_router_id = yandex_alb_http_router.course-app-http-router.id
      }
    }
  }

  depends_on = [yandex_alb_http_router.course-app-http-router]
}

resource "yandex_compute_instance" "prometheus" {
  name        = "prometheus"
  platform_id = "standard-v1"
  resources {
    cores  = 2
    memory = 4
  }
  boot_disk {
    initialize_params {
      image_id = "fd87e3vsemiab8q1tl0h"
      size     = 10
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.internal-netology-subnet-b.id
    nat       = true
  }
  metadata = {
    user-data = "${file("./meta.yml")}"
  }

  zone = "ru-central1-b"
}

resource "yandex_compute_instance" "grafana" {
  name        = "grafana"
  platform_id = "standard-v1"
  resources {
    cores  = 2
    memory = 4
  }
  boot_disk {
    initialize_params {
      image_id = "fd87e3vsemiab8q1tl0h"
      size     = 10
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.external-netology-subnet-a.id
    nat       = true
  }
  metadata = {
    user-data = "${file("./meta.yml")}"
  }

  zone = "ru-central1-a"
}

resource "yandex_compute_instance" "elasticsearch" {
  name        = "elasticsearch"
  platform_id = "standard-v1"
  resources {
    cores  = 2
    memory = 4
  }
  boot_disk {
    initialize_params {
      image_id = "fd87e3vsemiab8q1tl0h"
      size     = 10
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.internal-netology-subnet-b.id
    nat       = true
  }
  metadata = {
    user-data = "${file("./meta.yml")}"
  }

  zone = "ru-central1-b"
}

resource "yandex_compute_instance" "kibana" {
  name        = "kibana"
  platform_id = "standard-v1"
  resources {
    cores  = 2
    memory = 4
  }
  boot_disk {
    initialize_params {
      image_id = "fd87e3vsemiab8q1tl0h"
      size     = 10
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.external-netology-subnet-a.id
    nat       = true
  }
  metadata = {
    user-data = "${file("./meta.yml")}"
  }

  zone = "ru-central1-a"
}