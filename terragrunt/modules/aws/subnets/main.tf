data "aws_availability_zones" "this" {
  state = "available"
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  vpc_id            = var.vpc_id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = data.aws_availability_zones.this.names[count.index]

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-${data.aws_availability_zones.this.names[count.index]}-private"
    }
  )
}


resource "aws_subnet" "public" {
  count = length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  vpc_id            = var.vpc_id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = data.aws_availability_zones.this.names[count.index]

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-${data.aws_availability_zones.this.names[count.index]}-public"
    }
  )
}