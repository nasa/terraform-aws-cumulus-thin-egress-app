output "distribution_url" {
  value = module.thin_egress_app.api_endpoint
}

output "rest_api_id" {
  value = module.thin_egress_app.rest_api.id
}

output "root_resource_id" {
  value = module.thin_egress_app.rest_api.root_resource_id
}

output "thin_egress_app_redirect_uri" {
  value = module.thin_egress_app.urs_redirect_uri
}

output "egress_log_group" {
  value = module.thin_egress_app.egress_log_group
}
