resource "aws_athena_database" "example" {
  name   = "wu8_athena_database"
  bucket = "wu8process"
}