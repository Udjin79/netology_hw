resource "yandex_compute_disk" "disk" {
  count = 3
  name  = "disk-${count.index + 1}"
  size  = var.storage_disk_size
}

resource "yandex_compute_instance" "storage" {
  name = "storage"

  resources {
    cores         = var.storage_cores
    memory        = var.storage_memory
    core_fraction = var.storage_core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = var.storage_image_id
    }
  }

  dynamic "secondary_disk" {
    for_each = yandex_compute_disk.disk
    content {
      disk_id = secondary_disk.value.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
  }

  metadata = var.metadata
}
