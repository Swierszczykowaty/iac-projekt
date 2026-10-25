terraform {
  required_providers {
    random = { source = "hashicorp/random" }
  }
}

resource "random_pet" "nazwa" {
  length = 2
}

output "nazwa_projektu" {
  value = random_pet.nazwa.id
}
