job "countdash" {
  datacenters = ["dc1"]

  group "api" {
    network {
      mode = "bridge"
      port "http" {
        to = 9001
      }
    }

    service {
      name = "counter-api"
      port = "http"
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
      port = "http"
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

      template {
      data = <<EOH
{{ with service "counter-api" }}
{{ with index . 0 }}
COUNTING_SERVICE_URL="http://{{ .Address }}:{{ .Port }}"{{ end }}{{ end }}
EOH
        destination = "count_service.env"
        env         = true
      }
    }
  }
}
