#------------------------------------------------------------------------------ SG BASTION  ------ 
data "http" "ip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_security_group" "StoreOneSG-Bastion" {
  name   = "StoreOneSG-Bastion"
  vpc_id = "${aws_vpc.StoreOne-VPC.id}"

  tags = {
    Name = "StoreOneSG-Bastion"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["${chomp(data.http.ip.body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# SG - DB  -------------------------------------------------------- DB Tier Security Group
resource "aws_security_group" "StoreOneSG-DB" {
  name = "StoreOneSG-DB" # SG 3306 

  vpc_id = "${aws_vpc.StoreOne-VPC.id}"

  tags = {
    Name = "StoreOneSG-DB-EBS"
  }

  # ingress {
  #   from_port   = 3306          # MariaDB port
  #   to_port     = 3306
  #   protocol    = "TCP"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "allow-maria-db" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.StoreOneSG-DB.id}"
  source_security_group_id = "${aws_security_group.StoreOneSG-ec2.id}"
}

#---------------------------------------------------------------------------- SG - EFS  ------ 
data "aws_vpc" "StoreOne-VPC" {
  id = "${aws_vpc.StoreOne-VPC.id}"
}

resource "aws_security_group" "StoreOneSG-EFS" {
  name        = "StoreOneSG-EFS"
  description = "Allows NFS traffic from instances within the VPC."
  vpc_id      = "${aws_vpc.StoreOne-VPC.id}"

  tags {
    Name = "StoreOneSG-EFS"
  }

  ingress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"

    cidr_blocks = ["${data.aws_vpc.StoreOne-VPC.cidr_block}"]
  }

  egress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"

    cidr_blocks = ["${data.aws_vpc.StoreOne-VPC.cidr_block}"]
  }
}

# SG - ec2  -------------------------------------------------------- Web/App Tier Security Group
resource "aws_security_group" "StoreOneSG-ec2" {
  name = "StoreOneSG-ec2-EBS" # SG 22

  vpc_id = "${aws_vpc.StoreOne-VPC.id}"

  tags = {
    Name = "StoreOneSG-ec2"
  }

  # ingress {
  #   from_port   = 22            # SSH Port
  #   to_port     = 22
  #   protocol    = "TCP"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "allow-http" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.StoreOneSG-ec2.id}"
  source_security_group_id = "${aws_security_group.StoreOneSG-LB.id}"
}

resource "aws_security_group_rule" "allow-ssh-from-Bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.StoreOneSG-ec2.id}"
  source_security_group_id = "${aws_security_group.StoreOneSG-Bastion.id}"
}

resource "aws_security_group_rule" "allow-nfs-from-EFS" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.StoreOneSG-ec2.id}"
  source_security_group_id = "${aws_security_group.StoreOneSG-EFS.id}"
}

# SG - LB  -------------------------------------------------------- ELB Security Group
resource "aws_security_group" "StoreOneSG-LB" {
  name = "StoreOneSG-LB-EBS" # SG 80

  vpc_id = "${aws_vpc.StoreOne-VPC.id}"

  tags = {
    Name = "StoreOneSG-LB"
  }

  ingress {
    from_port   = 80            # HTTP Port
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
