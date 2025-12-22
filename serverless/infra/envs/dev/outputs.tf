output "website_endpoint" {
  value = module.website.website_endpoint
}

output "bucket_name" {
  value = module.website.bucket_name
}

output "api_base_url" {
  value = module.api.api_base_url
}

output "hello_url" {
  value = module.api.hello_url
}
