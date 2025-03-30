terraform {
  backend "s3" {
    bucket         = "joy-tf-rb"
    key            = "environments/dev/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "joy-tf-locks"
    encrypt        = true
  }
}