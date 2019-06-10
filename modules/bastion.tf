/*
# -------------------------------------------------- LOCAL VARIABLES ------------------------------
locals {
  # MOUNT_TARGET = "${module.StoreOne-VPC-PRODUCTION.efs-mount-target-dns-A}"
  MOUNT_TARGET = "${aws_efs_mount_target.A.dns_name}"
}
*/

# --------------------------------------------- BASTION /JUMPING HOST ------------------------------

resource "aws_instance" "bastion" {
  ami                         = "ami-0a313d6098716f372"
  instance_type               = "t2.micro"
  associate_public_ip_address = "true"
  key_name                    = "myKey"
  availability_zone           = "us-east-1a"
  subnet_id                   = "${aws_subnet.StoreOne-PubSN1.id}"
  vpc_security_group_ids      = ["${aws_security_group.StoreOneSG-Bastion.id}"]

  tags {
    Name = "Bastion Host"
  }
}

/*
# --------------------------- NULL RESOUCE TO WORK WITH THE EC2 INSTANCE FROM THE AUTO SCALING GROUP
resource "null_resource" "inst1-copy" {
  provisioner "file" {
    source      = "./modules/mountefs.sh"
    destination = "~/mountefs.sh"

    connection {
      type        = "ssh"
      host        = "${aws_instance.inst1.private_ip}"
      user        = "ubuntu"
      private_key = "${file("c:/tmp/AWS Keys/myKey.pem")}"
      timeout     = "10m"
      agent       = "false"

      # Bastion host 
      bastion_host        = "${aws_instance.bastion.public_ip}"
      bastion_user        = "ubuntu"
      bastion_private_key = "${file("c:/tmp/AWS Keys/myKey.pem")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 744 ~/mountefs.sh",
      "sudo sleep 180",                      # I had to add a sleep of 180 to get the "apt install apache2 -y" defined in userdate.sh, working ok.
      "~/mountefs.sh ${local.MOUNT_TARGET}",
    ]

    connection {
      host        = "${aws_instance.inst1.private_ip}"
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("c:/tmp/AWS Keys/myKey.pem")}"
      timeout     = "10m"
      agent       = "false"

      # Bastion host 
      bastion_host        = "${aws_instance.bastion.public_ip}"
      bastion_user        = "ubuntu"
      bastion_private_key = "${file("c:/tmp/AWS Keys/myKey.pem")}"
    }
  }
}
*/

