resource "aws_redshift_cluster" "example" {
  cluster_identifier   = "tf-redshift-cluster"
  database_name        = "dev"
  master_username      = "wu8userredshift"
  master_password      = "Wu8passredshift"
  node_type            = "dc2.large"
  cluster_type         = "single-node"
  skip_final_snapshot  = true
  publicly_accessible  = true
}