
# #############################################
# # ACM OUTPUTS
# #############################################

# output "certificate_arn" {
#   description = "ARN of the ACM certificate"
#   value       = module.acm.certificate_arn
# }

# output "certificate_status" {
#   description = "Current status of the ACM certificate"
#   value       = module.acm.certificate_status
# }

# output "external_dns_validation_records" {
#   description = "DNS records to create manually when using external DNS"
#   value       = module.acm.external_dns_validation_records
# }

#############################################
# ELB OUTPUTS
#############################################

output "lb_dns_name" {
  description = "DNS name of the load balancer — use in Route53 alias records"
  value       = module.nlb.lb_dns_name
}

