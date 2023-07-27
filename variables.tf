variable "project_id" {
  description = "Project ID."
  type        = string
}

variable "network" {
  description = "VPC name."
  type        = string
}

variable "peering_range" {
  description = "Peering CIDR range"
  type        = string
}

variable "support_range" {
  description = "Support CIDR range of length /28 (required by Apigee for troubleshooting purposes)."
  type        = string
}

variable "psc_ingress_network" {
  description = "PSC ingress VPC name."
  type        = string
}

variable "psc_ingress_subnets" {
  description = "Subnets for exposing Apigee services via PSC"
  type = list(object({
    name               = string
    ip_cidr_range      = string
    region             = string
    secondary_ip_range = map(string)
  }))
  default = []
}

variable "apigee_envgroups" {
  description = "Apigee Environment Groups."
  type = map(object({
    hostnames = list(string)
  }))
  default = null
}

variable "apigee_instances" {
  description = "Apigee Instances (only one instance for EVAL orgs)."
  type = map(object({
    region       = string
    ip_range     = string
    environments = list(string)
  }))
  default = null
}

