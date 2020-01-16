terraform {
  required_version = ">= 0.12"
  # backend "s3" {
  #   encrypt = "true"
  #   bucket  = "terraform-monitoring-ec2"
  #   region  = "us-east-1"
  #   key     = "ec2/terraform.tfstate"
  # }
}

provider "aws" {
  region                  = "${var.region}"  
  profile                 = "${var.profile}"
}
