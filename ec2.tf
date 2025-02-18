resource "aws_instance" "cgv_bastion" {
  ami                    = "ami-0ea4d4b8dc1e46212"
  instance_type          = "t2.micro"
  key_name               = "chill-key"
  vpc_security_group_ids = [aws_security_group.eks_secu.id]
  availability_zone      = "${var.region}a"
  private_ip             = "10.0.0.10"
  user_data = templatefile("./eks.sh", {
    region     = var.region
    name       = "${var.name}-clu"
    access_key = var.access_key
    secret_key = var.secret_key
  })
  subnet_id                   = aws_subnet.eksnet_bastion[0].id
  associate_public_ip_address = true

  tags = {
    Name = "${var.name}-bastion"
  }
  depends_on = [
    aws_eks_cluster.main
    ]
}

output "pub_ip" {
  value = aws_instance.cgv_bastion.public_ip
}

