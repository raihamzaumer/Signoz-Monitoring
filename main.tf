

# ================ VPC ===================
module "vpc" {
  source = "../modules/VPC"

  vpc_name = var.vpc_name
  vpc_cidr = var.vpc_cidr

  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_nat_gateway = var.enable_nat_gateway

  enable_elb_sg = var.enable_elb_sg
  enable_app_sg = var.enable_app_sg
  enable_db_sg  = var.enable_db_sg

 

  app_ingress_rules = var.app_ingress_rules

  db_port = var.db_port

  tags = var.tags
}

# ===================== ACM ==========================
module "acm" {
  source = "../modules/ACM"

  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  name_prefix               = var.name_prefix

  validation_method      = var.validation_method
  create_route53_records = var.create_route53_records # ← no Route53 touched
  wait_for_validation    = var.wait_for_validation    # ← don't wait; you'll add records manually

  tags = var.tags
}

# ========================== ELB ================================
module "nlb" {
  source = "../modules/ELB"

  name_prefix                = var.name_prefix
  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.public_subnet_ids
  load_balancer_type         = var.load_balancer_type
  internal                   = var.internal
  enable_deletion_protection = false

  target_groups = var.target_groups
  enable_cross_zone_load_balancing = true
  

  listeners = {

    http = {                          # ← ADD THIS
    port     = 80
    protocol = "TCP"

    default_action = {
      type             = "forward"
      target_group_key = "signoz"
    }
    }
    tls = {
      port            = 443
      protocol        = "TLS"
      certificate_arn = module.acm.certificate_arn
      ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"

      default_action = {
        type             = "forward"
        target_group_key = "signoz"
      }
    }
    tcp = {
      port            = 4317
      protocol        = "TCP"

      default_action = {
        type             = "forward"
        target_group_key = "otel-grpc"
      }
    }
  }

  tags = var.tags
}

# ====================== ASG ========================

module "asg" {
  source = "../modules/ASG"

  name_prefix   = var.name_prefix
  ami_id        = var.ami_id
  instance_type = var.instance_type
  user_data     = file("./user_data.sh")

  enable_ssm = var.enable_ssm

  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.vpc.app_sg_id]

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period
  target_group_arns = [
    module.nlb.target_group_arns["signoz"],
    module.nlb.target_group_arns["otel-grpc"]
  ]


  # IAM profile for SSM + CloudWatch agent
  create_iam_instance_profile = var.create_iam_instance_profile
  iam_role_name               = var.iam_role_name

  # Hardened IMDSv2 settings
  http_tokens                 = "required"
  http_put_response_hop_limit = 1

  # Monitoring and termination protection
  enable_monitoring       = var.enable_monitoring
  ebs_optimized           = var.ebs_optimized
  disable_api_termination = var.disable_api_termination

  # Custom root volume — encrypted gp3
  block_device_mappings = var.block_device_mappings


  # Rolling refresh on launch template change
  instance_refresh = var.instance_refresh

  tags = var.tags
}