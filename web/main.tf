terraform {
  required_providers {
    docker = { source = "kreuzwerker/docker", version = "~> 3.0" }
  }
}

provider "docker" {}

variable "port_zewnetrzny" {
  type    = number
  default = 8081
}

resource "docker_image" "nginx" {
  name = "nginx:alpine"
}

resource "docker_container" "web" {
  name  = "web-iac"
  image = docker_image.nginx.image_id
  ports {
    internal = 80
    external = var.port_zewnetrzny
  }
}

output "adres" {
  value = "http://localhost:${var.port_zewnetrzny}"
}
