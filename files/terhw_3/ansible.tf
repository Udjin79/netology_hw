resource "local_file" "inventory_cfg" {
  content = templatefile("${path.module}/inventory.tftpl",
        {
          webservers = yandex_compute_instance.web,
          databases  = yandex_compute_instance.db,
          storage    = [yandex_compute_instance.storage]
        }
  )
  filename = "${abspath(path.module)}/inventory"
}

resource "null_resource" "web_hosts_provision" {

  # Ждем, пока сервера поднимутся
  depends_on = [yandex_compute_instance.storage, local_file.inventory_cfg]

  # Даем серверам немного времени для старта.
  provisioner "local-exec" {
        command = "sleep 90"
  }

  # Запуск ansible-playbook
  provisioner "local-exec" {
        command  = "export ANSIBLE_HOST_KEY_CHECKING=False; ansible-playbook -i ${abspath(path.module)}/inventory playbook.yml"
        on_failure = continue # Делаем, чтобы продолжить выполнение, даже если что-то пойдет не так
        environment = { ANSIBLE_HOST_KEY_CHECKING = "False" }
  }

  triggers = {
        always_run      = "${timestamp()}" # Запускаем всегда, так как время постоянно меняется
        playbook_src_hash  = filemd5("${abspath(path.module)}/test.yml") # Добавляем перезапуск при изменении файла
        ssh_public_key  = var.metadata["ssh-keys"]
  }
}
