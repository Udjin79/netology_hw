locals {
  ssh_key = file(var.ssh_key_path)
  each_vm = [
    {
      vm_name     = var.vm_name_main
      cpu         = var.cpu_main
      ram         = var.ram_main
      disk_volume = var.disk_volume_main
    },
    {
      vm_name     = var.vm_name_replica
      cpu         = var.cpu_replica
      ram         = var.ram_replica
      disk_volume = var.disk_volume_replica
    }
  ]
}
