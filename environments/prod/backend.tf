terraform {
  backend "s3" {
    bucket         = "joy-tf-rb"
    key            = "environments/prod/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}