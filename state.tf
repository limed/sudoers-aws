terraform {
  backend "s3" {
    bucket         = "sudoers-terraform-state"
    key            = "sudoers-aws/terraform.tfstate"
    dynamodb_table = "sudoers-terraform-state"
    region         = "eu-west-1"
  }
}

