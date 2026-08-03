output "vpc_id" { value = aws_vpc.main.id }
output "vpc_cidr_block" { value = aws_vpc.main.cidr_block }
output "public_subnet_ids" { value = [aws_subnet.public_a.id, aws_subnet.public_b.id] }
output "private_subnet_ids" { value = [aws_subnet.private_a.id, aws_subnet.private_b.id] }
