resource "aws_instance" "webserver" {
  ami           = "ami-0e83be366243f524a"
  instance_type = "t2.micro"

  tags = {
    "Name" = "instance1"
  }

  key_name               = aws_key_pair.web.id
  vpc_security_group_ids = [aws_security_group.internet-access.id]
}

#Enabling ssh access
resource "aws_key_pair" "web" {
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "internet-access" {
  name        = "internet-access"
  description = "Allow all outbound connection over the internet"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

