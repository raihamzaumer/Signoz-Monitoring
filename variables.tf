# AWS region
variable "aws_region" {
  description = "AWS region"
  type        = string
}

# VPC Variables
variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "vpc_name" {
  description = "VPC Name"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
}

variable "anywhere_cidr" {
  description = "CIDR for open access (0.0.0.0/0)"
  type        = string
}

variable "db_port" {
  description = "Database port for private SG"
  type        = number
}


variable "app_ingress_rules" {
  description = "Ingress rules for app security group"
  type = list(object({
    port        = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
}

# variable "enable_eip" {
#   description = "Enable EIP for NAT Gateway"
#   type        = bool
# }
variable "enable_elb_sg" {
  description = "Enable ELB sg"
  type        = bool

}
variable "enable_app_sg" {
  description = "Enable app_sg"
  type        = bool

}

variable "enable_db_sg" {
  description = "Enable db_sg"
  type        = bool

}

####################### ACM ##############################
variable "domain_name" {
  type = string

}
variable "subject_alternative_names" {
  type = list(string)

  validation {
    condition     = alltrue([for san in var.subject_alternative_names : can(regex("^(\\*\\.)?([a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,}$", san))])
    error_message = "All subject_alternative_names must be valid domain names (e.g. api.example.com or *.example.com)."
  }

}
variable "name_prefix" {
  type = string

}
variable "validation_method" {
  type = string

}
variable "create_route53_records" {
  type = bool

}
variable "wait_for_validation" {
  type = bool

}
##################### ELB ####################

variable "load_balancer_type" {
  type = string

}

variable "internal" {
  type = bool

}
variable "enable_cross_zone_load_balancing" {
  type = bool
  default = false  
}


##################### ASG #########################

variable "ami_id" {
  type = string

}
variable "instance_type" {
  type = string

}

variable "min_size" {
  type = number

}
variable "max_size" {
  type = number

}
variable "desired_capacity" {
  type = number

}
variable "health_check_type" {
  type = string

}
variable "enable_ssm" {
  description = "Enable SSM Session Manager access for private instances"
  type        = bool
  default     = false
}
variable "health_check_grace_period" {
  type = number

}
variable "create_iam_instance_profile" {
  type = bool

}
variable "block_device_mappings" {
  description = "Block device mappings for EC2 instances"

  type = list(object({
    device_name = string

    ebs = object({
      volume_size           = number
      volume_type           = string
      encrypted             = bool
      delete_on_termination = bool
      iops                  = number
      throughput            = number
    })
  }))
}
variable "iam_role_name" {
  type = string

}
variable "enable_monitoring" {
  type = bool

}
variable "ebs_optimized" {
  type = bool

}
variable "disable_api_termination" {
  type = bool

}
variable "instance_refresh" {
  description = "Instance refresh configuration for Auto Scaling Group"

  type = object({
    strategy = string

    preferences = object({
      min_healthy_percentage = number
      instance_warmup        = number
    })
  })
}
variable "target_groups" {
  description = "Target group configuration"

  type = map(object({
    port        = number
    protocol    = string
    target_type = string

    health_check = object({
      interval            = number
      healthy_threshold   = number
      unhealthy_threshold = number
    })
  }))
}

################ TAGS
variable "tags" {
  description = "Common tags for resources"

  type = map(string)

  default = {
    Environment = "prod"
    Team        = "platform"
  }
}