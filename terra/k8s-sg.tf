resource "yandex_vpc_security_group" "k8s-sg" {
  name        = "k8s-sg"
  network_id  = yandex_vpc_network.develop.id

  # Разрешаем весь исходящий трафик в интернет (нужно для работы NAT-шлюза)
  egress {
    protocol       = "ANY"
    description    = "Permit all egress traffic to internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol          = "ANY"
    description       = "Permit all egress traffic inside security group"
    predefined_target = "self_security_group"
  }

  # Разрешаем весь внутренний трафик между нодами (критично для Kubernetes)
  ingress {
    protocol          = "ANY"
    description       = "Permit all ingress traffic inside security group"
    predefined_target = "self_security_group"
  }

  ingress {
     protocol       = "TCP"
     description    = "Allow ANY"
     v4_cidr_blocks = ["0.0.0.0/0"] 
     
   }
  ingress {
     protocol       = "TCP"
     description    = "Allow ANY"
     predefined_target = "loadbalancer_healthchecks"
     v4_cidr_blocks = ["0.0.0.0/0"] 

   }
}

