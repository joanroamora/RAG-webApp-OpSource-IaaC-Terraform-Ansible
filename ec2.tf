# Security Group para la instancia frontend
resource "aws_security_group" "frontend_sg" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "frontend-sg"
  }
}

# Instancia EC2 para el frontend (máquina Free Tier)
resource "aws_instance" "frontend" {
  ami                         = "ami-0a313d6098716f372"  # AMI de Ubuntu Server 20.04 LTS para us-west-2 (ajusta según la región)
  instance_type               = "t2.micro"              # Tipo Free Tier elegible
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  security_groups             = [aws_security_group.frontend_sg.name]

  tags = {
    Name = "frontend-instance"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y apache2
              EOF
}

# Security Group para la instancia backend
resource "aws_security_group" "backend_sg" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 5001
    to_port     = 5001
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.public_subnet.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "backend-sg"
  }
}

# Instancia EC2 para el backend (en subnet privada)
resource "aws_instance" "backend" {
  ami           = "ami-0a313d6098716f372"  # AMI de Ubuntu Server 20.04 LTS para us-west-2 (ajusta según la región)
  instance_type = "t3.medium"              # Tipo de instancia con más recursos (ajustar según tus necesidades)
  subnet_id     = aws_subnet.private_subnet.id
  security_groups = [aws_security_group.backend_sg.name]

  tags = {
    Name = "backend-instance"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y nginx
              EOF
}
