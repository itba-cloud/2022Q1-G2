locals {
  mime_types = jsondecode(file("${path.module}/data/mime.json"))
}