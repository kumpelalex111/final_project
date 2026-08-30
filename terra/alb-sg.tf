resource "yandex_vpc_security_group" "alb-test-sg" {
  name        = "alb-test-sg"
  description = "Полностью открытая группа безопасности для тестов ALB"
  network_id  = yandex_vpc_network.develop.id

  
  ingress {
    protocol       = "ANY"
    description    = "Allow all inbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  
  egress {
    protocol       = "ANY"
    description    = "Allow all outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
