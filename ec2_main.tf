provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_key_pair" "key_pair" {
  key_name   = "my-key-pair"
  public_key = file("C:/Users/loannguyent5/.ssh/my-key-pair.pub")

}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2_security_group"
  description = "Allow SSH and ICMP traffic"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Cho phép SSH từ mọi địa chỉ IP
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]  # Cho phép ping ICMP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  
  }
}

resource "aws_instance" "ec2_instance" {
  ami           = "ami-06650ca7ed78ff6fa"  
  instance_type = "t2.micro"
  key_name      = aws_key_pair.key_pair.key_name
  security_groups = [aws_security_group.ec2_sg.name]

  tags = {
    Name = "MyEC2Instance"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y openjdk-11-jdk
              sudo apt-get install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo curl -fsSL https://pkg.jenkins.io/debian/jenkins.io.key | sudo tee \
                /usr/share/keyrings/jenkins.asc
              sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable/ \
                $(lsb_release -cs) main > /etc/apt/sources.list.d/jenkins.list'
              sudo apt-get update -y
              sudo apt-get install -y jenkins
              sudo systemctl start jenkins
              sudo systemctl enable jenkins
            EOF
}

output "instance_public_ip" {
  value = aws_instance.ec2_instance.public_ip
}
