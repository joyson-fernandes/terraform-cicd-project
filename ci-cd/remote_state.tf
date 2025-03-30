data "terraform_remote_state" "dev" {
  backend = "s3"
  
  config = {
    bucket         = "joy-tf-rb"
    key            = "terraform.tfstate"  # Updated path to match your dev environment
    region         = "eu-west-2"
  }
}

data "terraform_remote_state" "prod" {
  backend = "s3"
  
  config = {
    bucket = "joy-tf-rb"
    key    = "environments/prod/terraform.tfstate"
    region = "eu-west-2"
  }
}