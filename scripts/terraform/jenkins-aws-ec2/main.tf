resource "aws_instance" "primary" {
  ami           = "ami-0e83be366243f524a"
  instance_type = "t2.micro"
  #running script
  user_data = file("../../bash/jenkins-setup.sh")
  tags = {
    "Name" = "Jenkins Server"
  }

  key_name               = aws_key_pair.web.id
  vpc_security_group_ids = [aws_security_group.primary.id]
}

#Enabling ssh access
resource "aws_key_pair" "web" {
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "primary" {
  # SSH Port
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Jenkins port
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound connection over the internet
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}