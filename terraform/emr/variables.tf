variable "service_name" {}

variable "applications" {
  type = "list"
}

variable "vpc_id" {}
variable "subnet_id" {}

variable "instance_profile" {}


variable "master_instance_type" {
  default = "m4.large"
}

variable "core_instance_type" {
  default = "m4.large"
}

variable "core_instance_count" {
  default = 1
}

variable "release_label" {
  default = "emr-5.7.0"
}

output "fqdn" {
  value = "${aws_route53_record.this.fqdn}"
}

output "service_sg_id" {
  value = "${aws_security_group.service.id}"
}

