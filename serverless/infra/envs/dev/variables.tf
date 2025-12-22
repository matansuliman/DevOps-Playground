variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "aws_profile" {
  type    = string
  default = "personal"
}

variable "project_name" {
  type    = string
  default = "serverless-demo"
}

variable "tags" {
  type = map(string)
  default = {
    Project = "serverless-demo"
    Env     = "dev"
  }
}
