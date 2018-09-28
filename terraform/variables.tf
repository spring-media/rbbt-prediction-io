locals {
  domain_name    = "prediction-io"
  storage_gb     = 10
  instance_type  = "t2.small.elasticsearch"
  instance_count = 1
}

output "server_instance_id" {
  value = "${aws_instance.server.id}"
}

output "es_endpoint" {
  value = "${aws_elasticsearch_domain.default.endpoint}"
}

output "spark_endpoint" {
  value = "${aws_emr_cluster.tf-predictionio-spark.master_public_dns}"
}

output "hbase_endpoint" {
  value = "${aws_emr_cluster.tf-predictionio-hbase.master_public_dns}"
}
