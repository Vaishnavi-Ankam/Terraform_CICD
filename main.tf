
provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "my_vpc" {

   cidr_block = "10.0.0.0/16"
   
   enable_dns_hostnames = true
}

resource "aws_subnet" "public_subnet" {

  vpc_id = aws_vpc.my_vpc.id

  cidr_block = "10.0.1.0/24"

  map_public_ip_on_launch = true

}

resource "aws_internet_gateway" "my_ig" {

  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "IG"
  }
  
}

resource "aws_route_table" "public_rt" {

  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_ig.id
  }
  
}

resource "aws_route_table_association" "public_rt_assoc" {

  subnet_id = aws_subnet.public_subnet.id

  route_table_id = aws_route_table.public_rt.id
  
}

resource "aws_security_group" "my_http_server_sg" {

  name = "my_http_server_sg"

  vpc_id = aws_vpc.my_vpc.id

  ingress {

    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {

    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1 //all protocol
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {

    name = "my_http_server_sg"

  }

}

resource "aws_instance" "http_server" {

  ami                    = data.aws_ami.aws-linux-2-latest.id
  key_name               = "ec2-ter-key-pair"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.my_http_server_sg.id]
  subnet_id              = aws_subnet.public_subnet.id

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.aws_key_pair)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y yum",
      "sudo yum install httpd -y",
      "sudo service httpd start",
      "echo Welcome to Vaishu -  Server is at ${self.public_dns} | sudo tee /var/www/html/index.html"
    ]
  }

  tags = {
    Name ="public_instance"
  }

}

resource "aws_subnet" "private_subnet" {

  vpc_id = aws_vpc.my_vpc.id

  cidr_block = "10.0.2.0/24"

}

resource "aws_eip" "my_eip" {

  vpc = true  
}

resource "aws_nat_gateway" "my_nat" {

  subnet_id = aws_subnet.public_subnet.id

  allocation_id = aws_eip.my_eip.id

  tags = {
    Name = "NAT"
  }
  
}

resource "aws_route_table" "private_rt" {

  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.my_nat.id
  }
  
}

resource "aws_route_table_association" "private_rt_assoc" {

  subnet_id = aws_subnet.private_subnet.id

  route_table_id = aws_route_table.private_rt.id
  
}


resource "aws_instance" "http_server_private" {

  ami                    = data.aws_ami.aws-linux-2-latest.id
  key_name               = "ec2-ter-key-pair"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.my_http_server_sg.id]
  subnet_id              = aws_subnet.private_subnet.id

  connection {
    type        = "ssh"
    host        = aws_instance.http_server.public_ip
    user        = "ec2-user"
    private_key = file(var.aws_key_pair)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y yum",
      "sudo yum install httpd -y",
      "sudo service httpd start",
      "echo Welcome to Vaishu Private -  Server is at ${self.private_ip} | sudo tee /var/www/html/index.html"
    ]
  }

  tags = {
    Name ="private_instance"
  }

}





