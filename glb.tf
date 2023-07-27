/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

resource "google_compute_backend_service" "psc_backend" {
  project               = var.project_id
  name                  = "apigee-backend"
  port_name             = "https"
  protocol              = "HTTPS"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  security_policy       = null
  dynamic "backend" {
    for_each = [for _, psc_neg in google_compute_region_network_endpoint_group.psc_neg : psc_neg.id]
    content {
      group = backend.value
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_url_map" "url_map" {
  project         = var.project_id
  name            = "apigee-map"
  default_service = google_compute_backend_service.psc_backend.id
}

resource "google_compute_target_https_proxy" "https_proxy" {
  project          = var.project_id
  name             = "apigee-proxy"
  url_map          = google_compute_url_map.url_map.id
  ssl_certificates = [google_compute_managed_ssl_certificate.google_cert.id]
}

resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  project               = var.project_id
  name                  = "apigee-fr"
  target                = google_compute_target_https_proxy.https_proxy.id
  ip_address            = google_compute_global_address.external_address.address
  port_range            = "443"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  labels                = {}
}
