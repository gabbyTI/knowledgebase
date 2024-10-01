terraform {
  backend "s3" {
    bucket         = "knowledgebase-terraform-backend"
    key            = "backend.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "terraform-backend"
  }
}