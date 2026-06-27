output "vpc-cidr-id" {
  value = aws_vpc.my-vpc.id
}
output "public-subnet-1-id" {
  value = aws_subnet.public_1.id
}
output "public-subnet-2-id" {
  value = aws_subnet.public_2.id
}
output "private-subnet-1-id" {
  value = aws_subnet.private_1.id
}
output "private-subnet-2-id" {
  value = aws_subnet.private_2.id
}          