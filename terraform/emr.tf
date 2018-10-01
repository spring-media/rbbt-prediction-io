module "hbase" {
  source = "./emr"

  service_name     = "hbase"
  applications     = ["Hadoop", "HBase", "ZooKeeper"]
  vpc_id           = "${data.aws_cloudformation_stack.vpc.outputs["VpcId"]}"
  subnet_id        = "${data.aws_cloudformation_stack.vpc.outputs["PrivateAlphaSubnetId"]}"
  instance_profile = "${aws_iam_instance_profile.this.arn}"
}

module "spark" {
  source = "./emr"

  service_name     = "spark"
  applications     = ["Spark"]
  vpc_id           = "${data.aws_cloudformation_stack.vpc.outputs["VpcId"]}"
  subnet_id        = "${data.aws_cloudformation_stack.vpc.outputs["PrivateAlphaSubnetId"]}"
  instance_profile = "${aws_iam_instance_profile.this.arn}"
}
