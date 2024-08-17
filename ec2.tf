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
          
              BACKEND_PRIVATE_IP="${aws_instance.backend.private_ip}"
              echo "export BACKEND_PRIVATE_IP=${aws_instance.backend.private_ip}" >> /etc/environment              

              git clone https://github.com/joanroamora/Full-RAG-webapp-OpenSource-UI.git
              cd Full-RAG-webapp-OpenSource-UI
              source /etc/environment
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
    Name = "backend-sg"
  }
}

# Instancia EC2 para el backend (en subnet privada)
resource "aws_instance" "backend" {
  ami           = "ami-04a81a99f5ec58529"  # AMI de Ubuntu Server 20.04 LTS para us-west-2 (ajusta según la región)
  instance_type = "t3.xlarge"              # Tipo de instancia con más recursos (ajustar según tus necesidades)
  subnet_id     = aws_subnet.private_subnet.id
  security_groups = [aws_security_group.backend_sg.id]
  key_name                    = "llaveUno" 

  root_block_device {
    volume_size = 32                # Tamaño del volumen en GB
    volume_type = "gp3"             # Tipo de volumen, igual que el predeterminado
  }

  tags = {
    Name = "backend-instance"
  }

  user_data = <<-EOF
              #!/bin/bash
              
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

  user_data = <<-EOF
              #!/bin/bash
              mkdir -p /home/ubuntu/.ssh
              echo "LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFb3dJQkFBS0NBUUVBajVlZEVVbFY4
Z3A1WTN0cnJQeHhySklaUmd0aDkyRWVjUkhCR1J6VjRQOUJtSTFkCjNqd3VlNFhpb3NtbXpuTFBw
bFM2QlVvRmNkL3Vya3B1YlhHVjVzVk90dk5jWXBqS3NadGh3TnZIODNnUk1nQzEKTE0vZnRadi9R
Y2JBYW1tNEMzNDN6RFFNRFFVVmdiUHhidTU4UEtUMUFteGlaZkhXd2dncld5eE5qZHpHTTlzQQpw
SWd2ckJUbHhRNmhaZEk3Ky9zQkcwbWlVK01ZcG5TeDBaRGIrL2Y2U296eVExT3NPYVhRNGJDMThs
VlJwRCs5CkV3enB4ODB5ZWxZZE9qSTFGWWFNR2lUcEJ0SSszaGR6ZmNCeFl4Uk14ZjJoK2hMUDhh
UTMzWHJnV2MwZTI5eE0KdGw4RmU3bWJYNFBrdW9CRjhhWGZ3b3h6QXUzMko3V0c4WVAxUHdJREFR
QUJBb0lCQUZmYTZjMEQwOFFOeUl1bgpuZy92UFJYYkpmK0hRMTk2V29mUDF4ZW9YdXdWQVd0M1F6
R1FITmlTNkVHMW80dTVEM2V6YTBXRkxxT240WDllCkp3WnJjczRKZHNuVlNIZERDUEYySW04L2lh
MWJqeG5LK1E3NytPSkRHZ0NDdklQZlB5NDVBYWE5U1lwRnpBeloKcmlTellld3crWCtNRlFCTzRa
bENLbFRVWEhjbzdFZ0ZaSnkwcnhVZHhVbG5ZK0xweVdVSGhaakF3bDRoRjR4SgpJbFNtaGFvMEJE
RkR4cmhnS3JqVVUrSmpCQ1VSbC9NRHUvTkw0U1ZUTGxiR1pqemJpcFFtbWJjM0hmSmY5U2RVCnpQ
TjBnalpRdzA4bE85VEpjUUVhbGhEaEJRWk9COGhNc3RrM0s5aGdVOGFxeEdBRzNWTXlxejlkWlFG
cEp1NUUKbnBldkIzRUNnWUVBeTdSeS9IZnV0TmVGZVJhY0lKTFRLMnJ3aDR1TThTVjA3L1VWamdv
ZjZwZDV6cjhEQUwxOQpKd1dkc0R2b3ZBOFhOeUVqNjJhYS9Sc2owblVabjh1L2xVL0x3MGdpTkJy
KzhETDZXbHMrM0FWK1YvRzJSY1VOCkVUYlFrcmp5b3BKc2k0MXBONmFLQzRYeEV0RHArblJaNFNt
a3p2bkpJdU1aVXFDbDYveFM0RHNDZ1lFQXRIU0sKenBpV3pMcnFUQUwxaHcycnNoKzV1TE4yTUZv
a0hYK29ucXFrYktUempPWDYyRE9UaEE5N0lYeGFpM25kTWYxcwpGdjBIaTZacVp1UHJBWjR3L3hz
SHB5bkhCTERMMXpJeHQ4V05xaStqUUVFdC9zcUNyTzA5Z01mallwSGVuV2VHCk05WENld1F5dDVQ
dllkeGFiaXAydWZneDB1aSswSnJYc3NoQzBzMENnWUFZTjJDQUVRWG9xOEpyVGJ2THg0aWgKSGJw
d2NxK1RyMTlDYzRGWGZHNms1ZE1PTi9qMGFwSnBSQ3FsMjhsa0tlc1ptNi80ZVI4dHZiODVjc0JV
RmRXMQp1MkcrMm1GdWpsTUdYUmtVQ3NyalB5Znc3b1E3c1J4SGtwdWpCYWVhbWd1YlgzbEZxMSsz
MVBsK3dpVStwL3hUClh5Ny9pQVJZU0dVblJIL1ZHUThGSndLQmdHc1FWaWFiQzZWdUpJSnlvdis4
MGFoK0FDK2djamZmMDF1WkdROEMKU1VtWVdGTzVReW13K0EyN0xaL0JhdXNqbzJQOGFudjlKZFBx
S1dqZ1F0Y1Q1eGdFRG5kVVp4cldWaXBZUW4wNAovWU1DZm9ZcDVjTXNuWGxCekdLeXRhc094cGgz
Q24ySWpybHoxUzlyMnZRaHk1bGZJay9WL0tHWXExV1MrUFMrCnNqN2xBb0dCQUxpbFVhZksyUUpm
NHRXZEdxMzhpY1dRTVpndk9IWDFMeFdYN3BITmRXRUtJanZKKzVrQ01xUTkKYkUzdUZiTW9IUGhx
RlJCY0Y4aEhERzA0VHFXZjhMWStjT0F0TFl3MmRrSytMaENGTExMR3ZlNmdPN1ppa01nZAozZFVO
RWVUdTVNWjc3aTdaUXpPV21NR1NWcVd1OVlSdlZIeGR0dElVdnVSZHZsVThWL1gyCi0tLS0tRU5E
IFJTQSBQUklWQVRFIEtFWS0tLS0t" | base64 --decode > /home/ubuntu/.ssh/llaveUno.pem
              chmod 400 /home/ubuntu/.ssh/llaveUno.pem
              chown ubuntu:ubuntu /home/ubuntu/.ssh/llaveUno.pem
              EOF

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
