terraform {
  backend "s3" {
    bucket         = "paperwurks-terraform-state"
    key            = "dev/terraform.tfstate"   
    region         = "eu-west-2"
    dynamodb_table = "paperwurks-terraform-state-lock"
    encrypt        = true
  }
}
