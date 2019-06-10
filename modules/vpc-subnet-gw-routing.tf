/*
VPC BEANSTALKVPC:             172.16.0.0/16         65534 hosts

BeanStalkPubSN-a	us-east-1a	172.16.0.0/24           254 hosts
BeanStalkPubSN-b	us-east-1b	172.16.1.0/24           254 hosts           
BeanStalkPubSN-c	us-east-1c	172.16.2.0/24           254 hosts

BeanStalkPrivSN-a	us-east-1a	172.16.100.0/24         254 hosts
BeanStalkPrivSN-b	us-east-1b	172.16.101.0/24         254 hosts
BeanStalkPrivSN-c	us-east-1c	172.16.102.0/24         254 hosts
*/

# ------------------------------------------------------------------- VPC --------------
resource "aws_vpc" "StoreOne-VPC" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "StoreOne-VPC"
  }
}

data "aws_availability_zones" "available" {}

# -------------------------------------------------------- PUBLIC SUBNETS --------------
# --------------------------------------------------------       PUB SN 1 --------------
resource "aws_subnet" "StoreOne-PubSN1" {
  vpc_id     = "${aws_vpc.StoreOne-VPC.id}"
  cidr_block = "172.16.0.0/24"

  tags {
    Name = "StoreOne-PubSN1"
  }

  availability_zone = "${data.aws_availability_zones.available.names[0]}"
}

# --------------------------------------------------------       PUB SN 2 --------------
resource "aws_subnet" "StoreOne-PubSN2" {
  vpc_id     = "${aws_vpc.StoreOne-VPC.id}"
  cidr_block = "172.16.1.0/24"

  tags {
    Name = "StoreOne-PubSN2"
  }

  availability_zone = "${data.aws_availability_zones.available.names[1]}"
}

# --------------------------------------------------------       PUB SN 3 --------------
resource "aws_subnet" "StoreOne-PubSN3" {
  vpc_id     = "${aws_vpc.StoreOne-VPC.id}"
  cidr_block = "172.16.2.0/24"

  tags {
    Name = "StoreOne-PubSN3"
  }

  availability_zone = "${data.aws_availability_zones.available.names[2]}"
}

# ---------------------------------------------------------- INTERNET GATEWAY --------------
resource "aws_internet_gateway" "StoreOne-IGW" {
  vpc_id = "${aws_vpc.StoreOne-VPC.id}"

  tags = {
    Name = "StoreOne-IGW"
  }
}

# --------------------------------------------------- ROUTING StoreOne-VPC THRU IGW --------
resource "aws_route_table" "StoreOne-RTPub" {
  vpc_id = "${aws_vpc.StoreOne-VPC.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.StoreOne-IGW.id}"
  }

  depends_on = ["aws_internet_gateway.StoreOne-IGW"]

  tags = {
    Name = "StoreOne-RTPub"
  }
}

# ---------------------------------- ROUTE TABLE ASSOCIATION: PubSN1 to RTPub ---------------
resource "aws_route_table_association" "StoreOne-RTAtoPubSN1" {
  subnet_id      = "${aws_subnet.StoreOne-PubSN1.id}"
  route_table_id = "${aws_route_table.StoreOne-RTPub.id}"
}

resource "aws_route_table_association" "StoreOne-RTAtoPubSN2" {
  subnet_id      = "${aws_subnet.StoreOne-PubSN2.id}"
  route_table_id = "${aws_route_table.StoreOne-RTPub.id}"
}

resource "aws_route_table_association" "StoreOne-RTAtoPubSN3" {
  subnet_id      = "${aws_subnet.StoreOne-PubSN3.id}"
  route_table_id = "${aws_route_table.StoreOne-RTPub.id}"
}

# -------------------------------------------------------- PRIVATE SUBNETS --------------
# --------------------------------------------------------    PRIVATE SN 1 --------------
resource "aws_subnet" "StoreOne-PrivSN1" {
  vpc_id     = "${aws_vpc.StoreOne-VPC.id}"
  cidr_block = "172.16.100.0/24"

  tags {
    Name = "StoreOne-PrivSN1"
  }

  availability_zone = "${data.aws_availability_zones.available.names[0]}"
}

# --------------------------------------------------------    PRIVATE SN 2 --------------
resource "aws_subnet" "StoreOne-PrivSN2" {
  vpc_id     = "${aws_vpc.StoreOne-VPC.id}"
  cidr_block = "172.16.101.0/24"

  tags {
    Name = "StoreOne-PrivSN2"
  }

  availability_zone = "${data.aws_availability_zones.available.names[1]}"
}

# --------------------------------------------------------    PRIVATE SN 3 --------------
resource "aws_subnet" "StoreOne-PrivSN3" {
  vpc_id     = "${aws_vpc.StoreOne-VPC.id}"
  cidr_block = "172.16.102.0/24"

  tags {
    Name = "StoreOne-PrivSN3"
  }

  availability_zone = "${data.aws_availability_zones.available.names[2]}"
}

# --------------------------------------------------------    ELASTIC IP --------------
# ELASTIC IP 
resource "aws_eip" "StoreOne-forNat" {
  vpc = true

  tags {
    Name = "StoreOne-EIP"
  }
}

# --------------------------------------------------------   NAT GATEWAY --------------
resource "aws_nat_gateway" "StoreOne-NATGW" {
  allocation_id = "${aws_eip.StoreOne-forNat.id}"
  subnet_id     = "${aws_subnet.StoreOne-PubSN1.id}"
  depends_on    = ["aws_internet_gateway.StoreOne-IGW"]
}

# --------------------------------------------------- ROUTING StoreOne-VPC THRU NAT GW --------
resource "aws_route_table" "StoreOne-RTPriv" {
  vpc_id = "${aws_vpc.StoreOne-VPC.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.StoreOne-NATGW.id}"
  }

  depends_on = ["aws_nat_gateway.StoreOne-NATGW"]

  tags {
    Name = "StoreOne-NATGW"
  }
}

# ---------------------------------- ROUTE TABLE ASSOCIATION: PubSN1 to RTPub ---------------
resource "aws_route_table_association" "StoreOne-RTAtoPrivSN1" {
  subnet_id      = "${aws_subnet.StoreOne-PrivSN1.id}"
  route_table_id = "${aws_route_table.StoreOne-RTPriv.id}"
}

resource "aws_route_table_association" "StoreOne-RTAtoPrivSN2" {
  subnet_id      = "${aws_subnet.StoreOne-PrivSN2.id}"
  route_table_id = "${aws_route_table.StoreOne-RTPriv.id}"
}

resource "aws_route_table_association" "StoreOne-RTAtoPrivSN3" {
  subnet_id      = "${aws_subnet.StoreOne-PrivSN3.id}"
  route_table_id = "${aws_route_table.StoreOne-RTPriv.id}"
}
