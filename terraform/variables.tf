locals {
  domain_name          = "prediction-io"
  storage_gb           = 10
  instance_type        = "t2.small.elasticsearch"
  instance_count       = 1
  vpc_id               = "${data.aws_cloudformation_stack.vpc.outputs["VpcId"]}"
  subnet_id            = "${data.aws_cloudformation_stack.vpc.outputs["PrivateAlphaSubnetId"]}"
  region               = "${data.aws_region.current.name}"
  account_id           = "${data.aws_caller_identity.current.account_id}"
  environment          = "production"
}

output "es_endpoint" {
  value = "${aws_elasticsearch_domain.default.endpoint}"
}

# output "spark_endpoint" {
#   value = "${module.spark.fqdn}"
# }

output "hbase_endpoint" {
  value = "${module.hbase.fqdn}"
}
