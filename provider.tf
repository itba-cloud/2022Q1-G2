provider "aws" {
  region = var.aws_region

  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "default"

  default_tags {
    tags = {
      author     = "Grupo 2"
      version    = 1
      university = "ITBA"
      subject    = "Cloud Computing"
      created-by = "terraform"
    }
  }
}