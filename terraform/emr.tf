module "hbase" {
  source = "./emr"

  service_name     = "hbase"
  applications     = ["Hadoop", "HBase", "ZooKeeper"]
  vpc_id           = "${data.aws_cloudformation_stack.vpc.outputs["VpcId"]}"
  subnet_id        = "${data.aws_cloudformation_stack.vpc.outputs["PrivateAlphaSubnetId"]}"
  instance_profile = "${aws_iam_instance_profile.this.arn}"
}

# aws emr spark on yarn is not compatible with pio — once we need more computing power,
# we should spin up a stand-alone spark server.
# https://lists.apache.org/thread.html/%3CCAMBzQgwCLj9QfmmB2uwQyUhprmD1cuAvvn4d2mENO-G2t7HcYQ@mail.gmail.com%3E
# module "spark" {
#   source = "./emr"

#   service_name     = "spark"
#   applications     = ["Spark"]
#   vpc_id           = "${data.aws_cloudformation_stack.vpc.outputs["VpcId"]}"
#   subnet_id        = "${data.aws_cloudformation_stack.vpc.outputs["PrivateAlphaSubnetId"]}"
#   instance_profile = "${aws_iam_instance_profile.this.arn}"
# }
