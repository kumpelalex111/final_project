data "yandex_compute_image" "ubuntu_2404_lts" {
    family = "ubuntu-2404-lts"
}

# Master node
resource "yandex_compute_instance" "k8s-master" {
    name        = "k8s-master"
    hostname    = "k8s-master"
    platform_id = "standard-v4a"
    zone        = var.default_zone
    
    resources {
        cores         = 2
        memory        = 4
        core_fraction = 20
    }
    
    boot_disk {
        initialize_params {
            image_id = data.yandex_compute_image.ubuntu_2404_lts.image_id
            type     = "network-hdd"
            size     = 10
        }
    }
    
    network_interface {
        subnet_id          = yandex_vpc_subnet.k8s-1.id
        nat                = false
        security_group_ids = [yandex_vpc_security_group.k8s-sg.id]
        ip_address         = "192.168.50.5"
    }

    metadata = {
        user-data          = file("./cloud-init.yml")
        serial-port-enable = 1
    }
    
    scheduling_policy { 
        preemptible = true 
    }
}

# определение worker nodes
locals {
    worker_nodes = {
        "worker-1" = {
            zone       = var.default_zone
            subnet_id  = yandex_vpc_subnet.k8s-1.id
            ip_address = "192.168.50.21"
        }
        "worker-2" = {
            zone       = var.backup_zone
            subnet_id  = yandex_vpc_subnet.k8s-2.id
            ip_address = "192.168.60.22"
        }
        
    }
}

# Worker nodes 
resource "yandex_compute_instance" "k8s-workers" {
    for_each    = local.worker_nodes
    name        = each.key
    hostname    = each.key
    platform_id = "standard-v4a"
    zone        = each.value.zone
    
    resources {
        cores         = 2
        memory        = 2
        core_fraction = 50
    }
    
    boot_disk {
        initialize_params {
            image_id = data.yandex_compute_image.ubuntu_2404_lts.image_id
            type     = "network-hdd"
            size     = 20
        }
    }
    
    network_interface {
        subnet_id          = each.value.subnet_id
        nat                = false
        security_group_ids = [yandex_vpc_security_group.k8s-sg.id]
        ip_address         = each.value.ip_address
    }

    metadata = {
        user-data = file("./cloud-init.yml")
    }
    
    scheduling_policy { 
        preemptible = true 
    }
    
    depends_on = [yandex_compute_instance.k8s-master]
}

# Inventory для Ansible
resource "local_file" "inventory" {
    content = <<-EOT
[all:vars]
ansible_ssh_common_args='-o ProxyCommand="ssh -p 22 -W %h:%p -q alex@${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}"'
ansible_user=alex

[master]
${yandex_compute_instance.k8s-master.network_interface.0.ip_address}

[workers]
%{ for worker in yandex_compute_instance.k8s-workers ~}
${worker.network_interface.0.ip_address}
%{ endfor ~}

[gitlab]
${yandex_compute_instance.gitlab.network_interface.0.ip_address}
    EOT
    filename = "/home/alex/diplom/ansible_kuber/hosts.ini"
    file_permission = "0644"
    
    depends_on = [
        yandex_compute_instance.k8s-master,
        yandex_compute_instance.k8s-workers,
        yandex_compute_instance.gitlab
    ]
}


output "master_ip" {
    value = yandex_compute_instance.k8s-master.network_interface.0.ip_address
}

output "worker_ips" {
    value = {
        for name, instance in yandex_compute_instance.k8s-workers :
        name => instance.network_interface.0.ip_address
    }
}

