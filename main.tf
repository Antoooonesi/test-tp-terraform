# VPC cool
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"  
}

# Créer une clé SSH
data "aws_key_pair" "my_key" {
  key_name   = "vockey"
  
}


# Groupe de sécurité pour SSH
resource "aws_security_group" "ssh_sg" {
  name        = "ssh-sg"

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
}

# Groupe de sécurité pour l'application
resource "aws_security_group" "app_sg" {
  name        = "app-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

# Route Table
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id
}

# Route par défaut vers l'Internet Gateway
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Sous-réseau public
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"  # Plage CIDR pour le subnet public
  map_public_ip_on_launch = true
}

# Sous-réseau privé
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.2.0/24"  # Plage CIDR pour le subnet privé
}

# Association du subnet public avec la route table
resource "aws_route_table_association" "public_subnet_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.route_table.id
}

# Elastic IP pour le NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"  # Utilise l'attribut mis à jour
}

# NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id
}

# Table de routage pour le subnet privé
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
}

# Route dans la table privée vers le NAT Gateway
resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}

# Association du subnet privé avec la route table privée
resource "aws_route_table_association" "private_subnet_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

# Instance Ubuntu (bastion)
resource "aws_instance" "bastion2" {
  ami           = "ami-04b4f1a9cf54c11d0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id

  key_name   = "vockey"
  vpc_security_group_ids = [aws_security_group.ssh_sg.id]

  tags = {
    Name = "Bastion"
  }
}

# Instance application (HTTPD)
resource "aws_instance" "application2" {
  ami           = "ami-04b4f1a9cf54c11d0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnet.id

  key_name   = "vockey"
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y apache2
              systemctl start apache2
              systemctl enable apache2
              EOF

  tags = {
    Name = "Application"
  }
}
