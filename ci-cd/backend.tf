terraform {
  backend "s3" {
    bucket         = "joy-tf-rb"
    key            = "ci-cd/terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}