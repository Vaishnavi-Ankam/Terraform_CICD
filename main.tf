provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "dev" {
    ami = "ami-05c3dc660cb6907f0"
    instance_type = "t2.nano"
    tags = {
      Name = "dev-ec3"
    }
}
