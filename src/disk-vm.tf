resource "yandex_compute_disk" "disks" {
  count = 3
  name  = format("disk-%01d", count.index + 1)
  type  = "network-ssd"
  size  = 1
  zone  = var.default_zone

  labels = {
    environment = "netology"
  }
}

resource "yandex_compute_instance" "vm_storage" {
  count       = 1
  name        = "storage"
  hostname    = "storage"
  description = "storage"
  zone        = var.default_zone
  folder_id   = var.folder_id

  platform_id               = var.web_platform_id
  allow_stopping_for_update = true

  resources {
    cores         = 2
    memory        = 1
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.debian_11.id
      type     = "network-ssd"
      size     = "15"
    }
  }

  dynamic "secondary_disk" {
    for_each = yandex_compute_disk.disks.*.id
    content {
      disk_id = secondary_disk.value
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.develop.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.example.id]
  }

  metadata = {
    ssh-keys = "debian:${local.ssh_file}"
  }

  scheduling_policy {
    preemptible = true
  }
}
