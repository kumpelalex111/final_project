# Создаем статический публичный IP-адрес
resource "yandex_vpc_address" "alb_ip" {
  name = "alb-public-ip"
  external_ipv4_address {
    zone_id = var.default_zone
  }
}

# Локальные переменные для доменов
locals {
  alb_ip = yandex_vpc_address.alb_ip.external_ipv4_address[0].address
  
  gitlab_domain  = "gitlab.${local.alb_ip}.sslip.io"
  grafana_domain = "grafana.${local.alb_ip}.sslip.io"
  app_domain     = "app.${local.alb_ip}.sslip.io"
}

resource "yandex_alb_target_group" "gitlab-tg" {
  name = "gitlab-tg"

  target {
    subnet_id  = yandex_vpc_subnet.k8s-1.id
    ip_address = var.ip_gitlab
  }
}

resource "yandex_alb_target_group" "grafana-tg" {
  name = "grafana-tg"

  target {
    subnet_id  = yandex_vpc_subnet.k8s-1.id
    ip_address = var.ip_k8s_worker-1
  }
  target {
    subnet_id  = yandex_vpc_subnet.k8s-2.id
    ip_address = var.ip_k8s_worker-2
  }
}

resource "yandex_alb_target_group" "app-tg" {
  name = "app-tg"

  target {
    subnet_id  = yandex_vpc_subnet.k8s-1.id
    ip_address = var.ip_k8s_worker-1 
  }
  target {
    subnet_id  = yandex_vpc_subnet.k8s-2.id
    ip_address = var.ip_k8s_worker-2
  }
}


resource "yandex_alb_backend_group" "gitlab-bg" {
  name = "gitlab-bg"

  http_backend {
    name             = "gitlab-http-backend"
    weight           = 1
    port             = 80
    target_group_ids = [yandex_alb_target_group.gitlab-tg.id]
    
    load_balancing_config {
      panic_threshold = 90
    }    
    
    healthcheck {
      timeout             = "1s"
      interval            = "3s"
      healthy_threshold   = 2
      unhealthy_threshold = 2
      
      http_healthcheck {
        path = "/-/healthy"
      }
    }
  }
}

resource "yandex_alb_backend_group" "grafana-bg" {
  name = "grafana-bg"

  http_backend {
    name             = "grafana-backend"
    weight           = 1
    port             = var.grafana_nodeport
    target_group_ids = [yandex_alb_target_group.grafana-tg.id]

    healthcheck {
      timeout  = "1s"
      interval = "3s"
      
      http_healthcheck {
        path = "/api/health"
      }
    }
  }
}

resource "yandex_alb_backend_group" "app-bg" {
  name = "app-backend-group"

  http_backend {
    name             = "app-backend"
    weight           = 1
    port             = var.app_nodeport
    target_group_ids = [yandex_alb_target_group.app-tg.id]
    
    healthcheck {
      timeout  = "1s"
      interval = "3s"
      
      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "tf_router" {
  name = "main-http-router"
}

# используем locals для доменов
resource "yandex_alb_virtual_host" "gitlab_vhost" {
  name           = "gitlab-vhost"
  http_router_id = yandex_alb_http_router.tf_router.id
  authority      = [local.gitlab_domain]

  route {
    name = "gitlab-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.gitlab-bg.id
        timeout          = "60s"
      }
    }
  }
}

resource "yandex_alb_virtual_host" "grafana_vhost" {
  name           = "grafana-vhost"
  http_router_id = yandex_alb_http_router.tf_router.id
  authority      = [local.grafana_domain]

  route {
    name = "grafana-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.grafana-bg.id
        timeout          = "60s"
      }
    }
  }
}

resource "yandex_alb_virtual_host" "app_vhost" {
  name           = "app-vhost"
  http_router_id = yandex_alb_http_router.tf_router.id
  authority      = [local.app_domain]

  route {
    name = "app-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.app-bg.id
        timeout          = "60s"
      }
    }
  }
}

resource "yandex_alb_load_balancer" "main_alb" {
  name               = "main-application-balancer"
  network_id         = yandex_vpc_network.develop.id
  security_group_ids = [yandex_vpc_security_group.alb-test-sg.id]

  allocation_policy {
    location {
      zone_id   = var.default_zone
      subnet_id = yandex_vpc_subnet.k8s-1.id
    }
  }

  listener {
    name = "http-listener"
    endpoint {
      address {
        external_ipv4_address {
          address = local.alb_ip  # зарезервированный IP
        }
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.tf_router.id
      }
    }
  }

  
}

output "service_urls" {
  value = {
    gitlab  = "http://${local.gitlab_domain}"
    grafana = "http://${local.grafana_domain}"
    app     = "http://${local.app_domain}"
  }
}