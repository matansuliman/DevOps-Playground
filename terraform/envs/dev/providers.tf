provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = {
      Project   = "legi-bit"
      Env       = var.env
      Owner     = "matan"
      ManagedBy = "terraform"
    }
  }
}
