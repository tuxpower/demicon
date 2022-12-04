data "aws_vpc" "selected" {
  tags = {
    Name = var.vpc_name
  }
}

data "aws_subnet" "default" {
  availability_zone = element(var.aws_availability_zones, count.index)
  vpc_id            = data.aws_vpc.selected.id
  state             = "available"

  count = length(var.aws_availability_zones)
}

data "aws_security_group" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}
