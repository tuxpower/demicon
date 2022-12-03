terraform {
  backend "s3" {
    region         = "eu-west-1"
    bucket         = "josegaspar-terraform-state"
    key            = "terraform.tfstate"
    dynamodb_table = "josegaspar-terraform-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region  = "eu-west-1"
}

