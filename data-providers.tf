data "aws_ami" "aws-linux-2-latest" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm*"]
  }
}

data "aws_ami_ids" "aws-linux-2-latest-ids" {

  owners = ["amazon"]

}


