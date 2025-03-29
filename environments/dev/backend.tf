terraform {
  backend "s3" {
    bucket         = "joy-tf-rb"
    key            = "terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "joy-tf-locks"
    encrypt        = true
  }
}