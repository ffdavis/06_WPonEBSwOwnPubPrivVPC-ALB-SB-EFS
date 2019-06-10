resource "aws_efs_file_system" "StoreOneEFS" {
  creation_token = "StoreOne-fs"

  tags {
    Name = "StoreOneEFS"
  }
}

resource "aws_efs_mount_target" "A" {
  file_system_id  = "${aws_efs_file_system.StoreOneEFS.id}"
  subnet_id       = "${aws_subnet.StoreOne-PrivSN1.id}"
  security_groups = ["${aws_security_group.StoreOneSG-EFS.id}"]
}

resource "aws_efs_mount_target" "B" {
  file_system_id  = "${aws_efs_file_system.StoreOneEFS.id}"
  subnet_id       = "${aws_subnet.StoreOne-PrivSN2.id}"
  security_groups = ["${aws_security_group.StoreOneSG-EFS.id}"]
}

resource "aws_efs_mount_target" "C" {
  file_system_id  = "${aws_efs_file_system.StoreOneEFS.id}"
  subnet_id       = "${aws_subnet.StoreOne-PrivSN3.id}"
  security_groups = ["${aws_security_group.StoreOneSG-EFS.id}"]
}

/*
locals {
  # MOUNT_TARGET = "${module.StoreOne-VPC-PRODUCTION.efs-mount-target-dns-A}"
  MOUNT_TARGET = "${aws_efs_mount_target.A.dns_name}"
}

# --------------------
data "template_file" "mountefstemplate" {
  template = "${file("modules/mountefstemplate")}"
}
*/
data "template_file" "mountefs" {
  template = <<EOF
commands:
  01_create_dir_fer:
    command: "/home/ec2-user/userdata.sh"
    # ignoreErrors: true

files:
  "/home/ec2-user/userdata.sh":
    mode: "000755"
    owner: root
    group: root
    content: |
      # Mount the EFS filesystem ##################################
      #!/bin/bash

      exec &>> /home/ec2-user/userdata.log 2>&1

      MOUNT_LOCATION="/mnt/efs"
      MOUNT_TARGET="${aws_efs_mount_target.A.dns_name}"

      # sudo apt update -y
      # sudo apt install -y nfs-common
      # sudo yum update -y
      # sudo yum install -y nfs-common
      
      sudo mkdir -p $MOUNT_LOCATION

      sudo mount \
        -t nfs4 \
        -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 \
        $MOUNT_TARGET:/ $MOUNT_LOCATION
EOF

  #  vars {
  #    efsdns = "${aws_efs_mount_target.A.dns_name}"
  #  }
}

resource "local_file" "mountfs" {
  content  = "${data.template_file.mountefs.rendered}"
  filename = "mydefaultphpapp/.ebextensions/00_userdata.config"
}
