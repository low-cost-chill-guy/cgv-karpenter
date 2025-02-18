resource "aws_route_table_association" "eks_bastion_rtass" {
  count          = 2
  subnet_id      = aws_subnet.eksnet_bastion[count.index].id
  route_table_id = aws_route_table.eks_eksnet_bastion_rt.id
}
resource "aws_route_table_association" "eks_man_rtaas" {
  count          = 2
  subnet_id      = aws_subnet.eksnet_ma[count.index].id
  route_table_id = aws_route_table.eks_node_rt.id
}
resource "aws_route_table_association" "eks_work_rtaas" {
  count          = 2
  subnet_id      = aws_subnet.eksnet_work[count.index].id
  route_table_id = aws_route_table.eks_node_rt.id
}

