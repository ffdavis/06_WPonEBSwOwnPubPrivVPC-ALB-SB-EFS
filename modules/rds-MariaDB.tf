resource "aws_db_instance" "storeone-db" {
  identifier             = "storeonedb"                               # DB Instance
  allocated_storage      = "5"
  storage_type           = "gp2"
  engine                 = "MariaDB"
  engine_version         = "10.2.21"
  instance_class         = "db.t2.micro"
  name                   = "storeonedb"
  username               = "rootfer"
  password               = "cacarulo99"
  parameter_group_name   = "default.mariadb10.2"
  skip_final_snapshot    = true                                       # this setup will allow to delete the RDS with terraform destroy.
  depends_on             = ["aws_security_group.StoreOneSG-DB"]
  vpc_security_group_ids = ["${aws_security_group.StoreOneSG-DB.id}"]
  db_subnet_group_name   = "${aws_db_subnet_group.StoreOneDBSNGN.id}"
  multi_az               = false
  publicly_accessible    = false
}

resource "aws_db_subnet_group" "StoreOneDBSNGN" {
  name       = "storeonedbsngn"
  subnet_ids = ["${aws_subnet.StoreOne-PrivSN1.id}", "${aws_subnet.StoreOne-PrivSN2.id}"]
}
