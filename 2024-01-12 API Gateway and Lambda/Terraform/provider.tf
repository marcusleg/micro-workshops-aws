terraform {
  required_providers {
    archive = {
      source = "hashicorp/archive"
      version = "2.4.1"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"

  allowed_account_ids = [724792572405]
}
