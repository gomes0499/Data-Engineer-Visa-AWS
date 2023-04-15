module "iam" {
    source = "./modules/iam"
}

module "kinesis" {
    source = "./modules/kinesis"
}

module "S3" {
    source = "./modules/s3"
}

module "redshift" {
    source = "./modules/redshift"
}


