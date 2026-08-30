resource "yandex_vpc_network" "develop" {
  name = "develop"
}
resource "yandex_vpc_subnet" "public" {
  name           = "public"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.public_cidr
  route_table_id = yandex_vpc_route_table.public-route-table.id
}
resource "yandex_vpc_subnet" "k8s-1" {
  name           = "k8s-1"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.k8s-1_cidr
  route_table_id = yandex_vpc_route_table.public-route-table.id
}
resource "yandex_vpc_subnet" "k8s-2" {
  name           = "k8s-2"
  zone           = var.backup_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.k8s-2_cidr
  route_table_id = yandex_vpc_route_table.public-route-table.id
}

resource "yandex_vpc_subnet" "bastion" {
  name           = "bastion"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.bastion_cidr
  
}

