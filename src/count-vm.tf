resource "yandex_compute_instance" "vm_web" {
  count                     = 2
  name                      = format("web-%01d", count.index + 1)
  hostname                  = format("web-%01d", count.index + 1)
  description               = format("web-%01d", count.index + 1)
  zone                      = var.default_zone
  folder_id                 = var.folder_id

  platform_id = var.web_platform_id
  allow_stopping_for_update = true
  
  resources {
    cores         = var.vms_resources["vm_web_resources"]["cores"]
    memory        = var.vms_resources["vm_web_resources"]["memory"]
    core_fraction = var.vms_resources["vm_web_resources"]["core_fraction"]
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.debian_11.id
      type     = "network-ssd"
      size     = "15"
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.develop.id
    nat        = true
    security_group_ids = [ yandex_vpc_security_group.example.id ]
  }

  metadata = {
    ssh-keys = "debian:${local.ssh_file}"
  }

  scheduling_policy {
    preemptible = true
  }
}
