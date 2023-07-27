locals {
  psc_subnet_region_name = { for subnet in var.psc_ingress_subnets :
    subnet.region => "${subnet.region}/${subnet.name}"
  }
}


resource "google_compute_global_address" "external_address" {
  name         = "apigee-external"
  project      = var.project_id
  address_type = "EXTERNAL"
}

locals {
  hostname   = "${replace(google_compute_global_address.external_address.address, ".", "-")}.nip.io"
  subdomains = [for subdomain in [for name, _ in var.apigee_envgroups : name] : "${subdomain}.${local.hostname}"]
  certname   = "cert-${replace(google_compute_global_address.external_address.address, ".", "")}"
  domains    = concat([local.hostname])
}

resource "google_compute_managed_ssl_certificate" "google_cert" {
  project = var.project_id
  name    = local.certname
  managed {
    domains = local.domains
  }
}

resource "google_compute_managed_ssl_certificate" "google_cert1" {
  project = var.project_id
  name    = "new-cert"
  managed {
    domains = ["${google_compute_global_address.external_address.address}.nip.io"]
  }
}

module "psc-ingress-vpc" {
  source                  = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-vpc?ref=v16.0.0"
  project_id              = var.project_id
  name                    = var.psc_ingress_network
  auto_create_subnetworks = false
  subnets                 = var.psc_ingress_subnets
}

resource "google_compute_region_network_endpoint_group" "psc_neg" {
  project               = var.project_id
  for_each              = var.apigee_instances
  name                  = "psc-neg-${each.value.region}"
  region                = each.value.region
  network               = module.psc-ingress-vpc.network.id
  subnetwork            = module.psc-ingress-vpc.subnet_self_links[local.psc_subnet_region_name[each.value.region]]
  network_endpoint_type = "PRIVATE_SERVICE_CONNECT"
  psc_target_service    = "projects/bce963405763e377bp-tp/regions/europe-west1/serviceAttachments/apigee-europe-west1-i2hs"
  lifecycle {
    create_before_destroy = true
  }
}