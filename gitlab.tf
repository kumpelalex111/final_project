resource "yandex_compute_instance" "gitlab" {
    name        = "gitlab"
    hostname    = "gitlab"
    platform_id = "standard-v4a"
    zone        =  var.default_zone
    resources {
        cores  = 2
        memory = 8
        core_fraction = 50
    }
    boot_disk {
        initialize_params {
            image_id = data.yandex_compute_image.ubuntu_2404_lts.image_id
            type = "network-hdd"
            size = 30
        }
    }
    network_interface {
        subnet_id  = yandex_vpc_subnet.k8s-1.id
        ip_address = yandex_vpc_address.gitlab_internal_ip.internal_ipv4_address[0].address
        nat        = false
        
    }

    metadata = {
        user-data = file("./cloud-init.yml")
        serial-port-enable = 1
    }
    scheduling_policy { preemptible = true }
}

# статический внутренний IP-адрес для GitLab
resource "yandex_vpc_address" "gitlab_internal_ip" {
  name = "gitlab-internal-ip"
  
  internal_ipv4_address {
    subnet_id = yandex_vpc_subnet.k8s-1.id
    address   = "192.168.50.17" 
  }
}
