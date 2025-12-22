resource "random_id" "suffix" {
  byte_length = 3
}

locals {
  bucket_name = "${var.project_name}-${random_id.suffix.hex}"
}

module "website" {
  source = "../../modules/s3-website"

  bucket_name    = local.bucket_name
  index_document = "index.html"
  error_document = "404.html"
  force_destroy  = true
  tags           = var.tags
}

module "visitors_table" {
  source = "../../modules/dynamodb-table"

  name          = "${var.project_name}-dev-visitors"
  hash_key_name = "pk"
  hash_key_type = "S"
  billing_mode  = "PAY_PER_REQUEST"
  tags          = var.tags
}

module "api" {
  source = "../../modules/api-lambda-http"

  name_prefix  = "${var.project_name}-dev"
  stage_name   = "prod"
  route_method = "GET"
  route_path   = "/hello"

  # CORS חייב להיות ה-origin של האתר (רק http://domain בלי path)
  cors_allow_origins = ["http://${module.website.website_endpoint}"]

  # הנתיב לתיקייה שמכילה handeler.py
  lambda_source_dir = "../../../lambda"

  # כי הקובץ אצלך נקרא handeler.py
  lambda_handler = "handeler.lambda_handler"

  tags = var.tags

  dynamodb_table_name = module.visitors_table.table_name
  dynamodb_table_arn  = module.visitors_table.table_arn
}
