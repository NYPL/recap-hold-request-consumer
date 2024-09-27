provider "aws" {
  region     = "us-east-1"
}

terraform {
  # Use s3 to store terraform state
  backend "s3" {
    bucket  = "nypl-github-actions-builds-qa"
    key     = "recap-hold-request-consumer-terraform-state"
    region  = "us-east-1"
  }
}

module "base" {
  source = "../base"
  environment = "qa"
}
