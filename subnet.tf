resource "aws_subnet" "eksnet_bastion" {
  count      = 2
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}${count.index == 0 ? "a" : "c"}"
  
  
  tags = {
     Name = "public-subnet"
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
#  tags = {
#    Name = "${var.name}-pub-${count.index == 0 ? "a" : "c"}"
#  }
}

resource "aws_subnet" "eksnet_ma" {
  count      = 2
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = "10.0.${count.index + 2}.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}${count.index == 0 ? "a" : "c"}"

  tags = {
    Name = "${var.name}-ma-${count.index == 0 ? "a" : "c"}"
  }
}

resource "aws_subnet" "eksnet_work" {
  count      = 2
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = "10.0.${count.index + 4}.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}${count.index == 0 ? "a" : "c"}"

  tags = {
    Name = "${var.name}-work-${count.index == 0 ? "a" : "c"}"
  }
}

