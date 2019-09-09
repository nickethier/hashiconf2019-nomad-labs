job "countdash" {
  datacenters = ["dc1"]

  group "api" {
    network {
      mode = "bridge"
    }

    service {
      name = "counter-api"
      port = "9001"

      connect{
        sidecar_service {}
      }
    }

    task "web" {
      driver = "docker"

      config {
        image = "hashicorpnomad/counter-api:v1"
      }

      resources {
        cpu    = 100
        memory = 64
      }
    }
  }

  group "dashboard" {
    constraint {
      attribute = "${node.unique.name}"
      value = "one"
    }

    network {
      mode = "bridge"
      port "http" {
        static = 8080
        to = 9002
      }
    }

    service {
      name = "count-dashboard"
      port = "9002"

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "count-api"
              local_bind_port = 8080
            }
          }
        }
      }
    }

    task "dashboard" {
      driver = "docker"

      config {
        image = "hashicorpnomad/counter-dashboard:v1"
      }

      resources {
        cpu    = 100
        memory = 64
      }
    }
  }
}
