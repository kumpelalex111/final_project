
resource "yandex_vpc_route_table" "public-route-table" {
  name       = "public-route-table"
  network_id = yandex_vpc_network.develop.id

  # Направляем весь трафик (0.0.0.0/0) шлюз k8s-nat-gw
  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.k8s-nat-gw.id
  }
  
}


