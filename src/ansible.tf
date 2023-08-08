resource "local_file" "hosts_cfg" {
  content = templatefile("${path.module}/hosts.tftpl",
    {
      webservers = yandex_compute_instance.vm_web,
      databases  = yandex_compute_instance.vm_web_2,
      storage    = yandex_compute_instance.vm_storage,
    }
  )
  filename = "${abspath(path.module)}/hosts.cfg"
}

resource "local_file" "playbook" {
  content = templatefile("${path.module}/playbook.tftpl",
    {
      ssh_user = var.vms_list.0.ssh_user
    }
  )
  filename = "${abspath(path.module)}/playbook.yaml"
}

resource "null_resource" "web_hosts_provision" {
depends_on = [ yandex_compute_instance.vm_web_2, yandex_compute_instance.vm_storage, local_file.playbook, local_file.hosts_cfg ]
  provisioner "local-exec" {                  
    command  = "export ANSIBLE_HOST_KEY_CHECKING=False; ansible-playbook -i ${abspath(path.module)}/hosts.cfg ${abspath(path.module)}/playbook.yaml"
    on_failure = continue
    environment = { ANSIBLE_HOST_KEY_CHECKING = "False" }
  }
    triggers = {  
      always_run         = "${timestamp()}" 
      playbook_src_hash  = file("${abspath(path.module)}/playbook.tftpl") 
      ssh_public_key     = local.ssh_file 
    }
}
