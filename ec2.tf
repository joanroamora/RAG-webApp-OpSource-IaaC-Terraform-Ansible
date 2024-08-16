# Security Group para la instancia frontend
resource "aws_security_group" "frontend_sg" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 5000
    to_port     = 5000
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
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "frontend-sg"
  }
}

# Instancia EC2 para el frontend (máquina Free Tier)
resource "aws_instance" "frontend" {
  ami                         = "ami-04a81a99f5ec58529"  # AMI de Ubuntu Server 20.04 LTS para us-west-2 (ajusta según la región)
  instance_type               = "t2.micro"              # Tipo Free Tier elegible
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  security_groups             = [aws_security_group.frontend_sg.id]
  key_name                    = "llaveUno" 

  depends_on = [aws_security_group.frontend_sg]

  tags = {
    Name = "frontend-instance"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              cd /home/ubuntu
              git clone https://github.com/joanroamora/Full-RAG-webapp-OpenSource-UI.git
              cd Full-RAG-webapp-OpenSource-UI
              sudo apt-get install -y python3-pip
              sudo apt install -y python3.12-venv
              python3 -m venv myenv
              
              source myenv/bin/activate
              pip3 install -r requirements.txt
              sudo mkdir temp
              python3 app.py
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
  ami           = "ami-04a81a99f5ec58529"  # AMI de Ubuntu Server 20.04 LTS para us-west-2 (ajusta según la región)
  instance_type = "t3.medium"              # Tipo de instancia con más recursos (ajustar según tus necesidades)
  subnet_id     = aws_subnet.private_subnet.id
  security_groups = [aws_security_group.backend_sg.id]
  key_name                    = "llaveUno" 

  tags = {
    Name = "backend-instance"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              git clone https://github.com/joanroamora/Full-RAG-webapp-OpenSource-BACKEND.git
              ls
              cd Full-RAG-webapp-OpenSource-BACKEND
              pip3 install -r requirements.txt
              curl -fsSL https://ollama.com/install.sh | sh
              ollama run llama3
              EOF
}

# Security Group para el Bastion Host
resource "aws_security_group" "bastion_sg" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Permitir acceso SSH desde cualquier lugar. Puede ser más restrictivo.
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-sg"
  }
}

# Instancia EC2 para el Bastion Host
resource "aws_instance" "bastion" {
  ami                         = "ami-04a81a99f5ec58529"  # AMI de Ubuntu Server 20.04 LTS para us-west-2
  instance_type               = "t3.micro"  # Un tipo de instancia pequeño, ajustable según tus necesidades
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  security_groups             = [aws_security_group.bastion_sg.id]
  key_name                    = "llaveUno" 

  tags = {
    Name = "bastion-host"
  }
}

# Permitir que el Bastion Host acceda a la instancia backend
resource "aws_security_group_rule" "allow_bastion_to_backend" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.backend_sg.id
  source_security_group_id = aws_security_group.bastion_sg.id
}
