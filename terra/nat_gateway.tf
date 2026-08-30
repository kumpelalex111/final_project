resource "yandex_vpc_gateway" "k8s-nat-gw" {
  name = "k8s-nat-gw"
  
  # Пустой блок shared_egress_gateway инициализирует стандартный NAT-шлюз
  shared_egress_gateway {}
}