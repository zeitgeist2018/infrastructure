terraform {
  required_version = ">= 1.1.7"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.8.0"
    }
  }

  backend s3 {
    acl = "bucket-owner-full-control"
    region = "us-east-1"
    encrypt = false
  }
}

provider aws {
  region = "us-east-1"
}
