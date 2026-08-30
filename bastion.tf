resource "yandex_compute_instance" "bastion" {
    name        = "bastion"
    hostname    = "bastion"
    platform_id = "standard-v4a"
    zone        =  var.default_zone
    resources {
        cores  = 2
        memory = 1
        core_fraction = 20
    }
    boot_disk {
        initialize_params {
            image_id = data.yandex_compute_image.ubuntu_2404_lts.image_id
            type = "network-hdd"
            size = 10
        }
    }
    network_interface {
        subnet_id = yandex_vpc_subnet.bastion.id
        nat       = true
        
    }

    metadata = {
        user-data = file("./cloud-init.yml")
        serial-port-enable = 1
    }
    scheduling_policy { preemptible = true }
}
