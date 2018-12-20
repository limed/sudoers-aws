terraform {
  backend "s3" {
    bucket = "sudoers-terraform-state"
    key    = "sudoers-aws/terraform.tfstate"
    region = "eu-west-1"
  }
}
