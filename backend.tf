terraform {
  backend "s3" {
    bucket       = "hcl-usecase5-terraform-state"
    key          = "terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
  }
}
