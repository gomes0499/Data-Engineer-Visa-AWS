module "iam" {
    source = "./modules/iam"
}

module "S3" {
    source = "./modules/s3"
}

module "redshift" {
    source = "./modules/redshift"
}

module "athena" {
    source = "./modules/athena"
}

# module "apigateway" {
#     source = "./modules/api-gateway"
# }

module "fargate" {
    source = "./modules/fargate"
}

module "msk" {
    source = "./modules/msk"
}