resource "aws_s3_bucket_object" "bucket_map_yaml" {
  bucket  = var.system_bucket
  key     = "${var.prefix}/thin-egress-app/bucket_map.yaml"
  content = templatefile("${path.module}/bucket_map.yaml.tmpl", { protected_buckets = var.protected_buckets, public_buckets = var.public_buckets })
  etag    = md5(templatefile("${path.module}/bucket_map.yaml.tmpl", { protected_buckets = var.protected_buckets, public_buckets = var.public_buckets }))
  tags    = var.tags
}

resource "aws_secretsmanager_secret" "thin_egress_urs_creds" {
  name_prefix = "${var.prefix}-tea-urs-creds-"
  description = "URS credentials for the ${var.prefix} Thin Egress App"
  tags        = var.tags
}

resource "aws_secretsmanager_secret_version" "thin_egress_urs_creds" {
  secret_id = aws_secretsmanager_secret.thin_egress_urs_creds.id
  secret_string = jsonencode({
    UrsId   = var.urs_client_id
    UrsAuth = base64encode("${var.urs_client_id}:${var.urs_client_password}")
  })
}

module "thin_egress_app" {
  source = "https://s3.amazonaws.com/asf.public.code/thin-egress-app/tea-terraform-build.61.zip"

  auth_base_url                      = var.urs_url
  bucket_map_file                    = aws_s3_bucket_object.bucket_map_yaml.key
  bucketname_prefix                  = ""
  config_bucket                      = var.system_bucket
  cookie_domain                      = var.cookie_domain
  domain_cert_arn                    = var.domain_cert_arn
  domain_name                        = var.distribution_url == null ? null : replace(replace(var.distribution_url, "/^https?:///", ""), "//$/", "")
  download_role_in_region_arn        = var.download_role_in_region_arn
  jwt_algo                           = var.jwt_algo
  jwt_secret_name                    = var.jwt_secret_name
  lambda_code_dependency_archive_key = var.lambda_code_dependency_archive_key
  log_api_gateway_to_cloudwatch      = var.log_api_gateway_to_cloudwatch
  permissions_boundary_name          = var.permissions_boundary_arn == null ? null : reverse(split("/", var.permissions_boundary_arn))[0]
  private_vpc                        = var.vpc_id
  stack_name                         = "${var.prefix}-thin-egress-app"
  stage_name                         = var.api_gateway_stage
  urs_auth_creds_secret_name         = aws_secretsmanager_secret.thin_egress_urs_creds.name
  vpc_subnet_ids                     = var.subnet_ids
}
