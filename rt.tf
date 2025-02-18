resource "aws_route_table" "eks_eksnet_bastion_rt" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = var.rocidr
    gateway_id = aws_internet_gateway.eks_ig.id
  }

  tags = {
    Name = "${var.name}-bastion-rt"
  }
}

resource "aws_route_table" "eks_node_rt" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = var.rocidr
    gateway_id = aws_internet_gateway.eks_ig.id
  }

  tags = {
    Name = "${var.name}-node-rt"
  }
}

