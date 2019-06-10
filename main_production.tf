locals {
  env = "PRDUCTION" # It could be PROD, STAGING, DEV, etc
}

provider "aws" {
  shared_credentials_file = "~/.aws/credentials"
  region                  = "us-east-1"          # us-east-1
  profile                 = "default"
}

module "StoreOne-VPC-PRODUCTION" {
  source = "./modules"
}

/*
output "ebs-id" {
  description = "ebs-id"
  value       = "${module.StoreOne-VPC-PRODUCTION.ebs-id}"
}
*/
/*
output "aws_instances_created" {
  description = "aws_instances_created"
  value       = "${module.StoreOne-VPC-PRODUCTION.aws_instances_created}"
}
*/
/*
Outputs:
aws_instances_created = [
    172.16.101.191,
    172.16.100.26
]
*/


/*
resource "null_resource" "runuserdataconfig" {
  provisioner "local-exec" {
    # command = "kubectl apply -f tmp/config-map-aws-auth_${var.cluster-name}.yaml --kubeconfig ${local_file.kubeconfig.filename}"
    command = "eb --version"
  }
}
*/

