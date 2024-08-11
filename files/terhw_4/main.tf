# Используем модуль для создания сети и подсети
module "vpc" {
  source = "./vpc"
  network_name = var.vpc_name
  subnet_name = "${var.vpc_name}-${var.default_zone}"
  zone = var.default_zone
  v4_cidr_blocks = var.default_cidr
}

module "test-vm" {
  source          = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
  env_name        = var.vpc_name
  network_id      = module.vpc.network_id
  subnet_zones    = [var.default_zone]
  subnet_ids      = [module.vpc.subnet_id]
  instance_name   = "web"
  instance_count  = 2
  image_family    = var.image_family
  public_ip       = var.public_ip
  
  metadata = {
      user-data          = data.template_file.cloudinit.rendered
      serial-port-enable = 1
  }
}

#Пример передачи cloud-config в ВМ для демонстрации №3
data "template_file" "cloudinit" {
 template = file("./cloud-init.yml")
vars = {
    public_key = var.public_key
  }
}

