resource "yandex_compute_instance" "vm_web_2" {
  depends_on = [ yandex_compute_instance.vm_web ]
  for_each = { for vm in var.vms_list : vm.vm_name => vm }
  name                      = each.value.vm_name
  hostname                  = each.value.vm_hostname
  description               = each.value.vm_discription
  zone                      = var.default_zone
  folder_id                 = var.folder_id

  platform_id = var.web_platform_id
  allow_stopping_for_update = true
  
  resources {
    cores         = each.value.cpu
    memory        = each.value.ram
    core_fraction = each.value.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.debian_11.id
      type     = each.value.disk_type
      size     = each.value.disk
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.develop.id
    nat        = true
    security_group_ids = [ yandex_vpc_security_group.example.id ]
  }

  metadata = {
    ssh-keys = "${each.value.ssh_user}:${local.ssh_file}"
  }

  scheduling_policy {
    preemptible = true
  }
}
