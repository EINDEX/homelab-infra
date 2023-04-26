resource "authentik_service_connection_docker" "local" {
  name  = "local"
  local = true
}

data "authentik_flow" "authentication_flow" {
  slug = "default-authentication-flow"
}
data "authentik_flow" "default_implicit_authorization_flow" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_group" "admins" {
  name = "administrators"
}

data "authentik_group" "users" {
  name = "users"
}

data "authentik_scope_mapping" "oauth" {
  managed_list = [
    "goauthentik.io/providers/oauth2/scope-email",
    "goauthentik.io/providers/oauth2/scope-openid",
    "goauthentik.io/providers/oauth2/scope-profile"
  ]
}


### OAuth Application Template
resource "authentik_provider_oauth2" "oauth_provider" {
  access_token_validity      = "hours=1"
  refresh_token_validity     = "weeks=2"
  for_each           = local.oauth_apps
  name               = each.value.name
  client_id          = each.value.client_id
  client_secret      = each.value.client_secret
  redirect_uris      = each.value.redirect_uris
  authorization_flow = data.authentik_flow.default_implicit_authorization_flow.id
  property_mappings  = data.authentik_scope_mapping.oauth.ids
}

resource "authentik_application" "oauth_app" {
  for_each           = local.oauth_apps
  name               = each.value.name
  slug               = each.key
  group              = each.value.group
  policy_engine_mode = "all"
  protocol_provider  = authentik_provider_oauth2.oauth_provider["${each.key}"].id
  meta_description   = each.value.desc
  meta_icon          = "/application-icons/${each.value.name}.png"
  meta_launch_url    = lookup(each.value, "url", "https://${each.key}.${var.domain}:${var.port}")
}

resource "authentik_policy_binding" "oauth_policy_binding" {
  for_each = local.oauth_apps
  target   = authentik_application.oauth_app["${each.key}"].uuid
  group    = lookup(each.value, "groups", "admin") != "users" ? data.authentik_group.admins.id : data.authentik_group.users.id
  order    = 0
}

### Proxy Application Template

resource "authentik_provider_proxy" "proxy_provider" {
  for_each           = local.proxy_apps
  name               = each.value.name
  external_host      = "https://${each.key}.${var.domain}:${var.port}"
  authorization_flow = data.authentik_flow.default_implicit_authorization_flow.id
  mode               = lookup(each.value, "mode", "forward_single")
  internal_host =  lookup(each.value, "internal_host", null)
  internal_host_ssl_validation = lookup(each.value, "internal_host_ssl_validation", null)
  access_token_validity     = "hours=1"
  refresh_token_validity     = "weeks=2"
  skip_path_regex    = lookup(each.value, "skip_path_regex", "")
}

resource "authentik_application" "proxy_app" {
  for_each           = local.proxy_apps
  name               = each.value.name
  slug               = each.key
  group              = each.value.group
  policy_engine_mode = "all"
  protocol_provider  = authentik_provider_proxy.proxy_provider["${each.key}"].id
  meta_description   = each.value.desc
  meta_icon          = "/application-icons/${each.value.name}.png"
  meta_launch_url    = lookup(each.value, "url", "https://${each.key}.${var.domain}:${var.port}")
}

resource "authentik_policy_binding" "proxy_policy_binding" {
  for_each = local.proxy_apps
  target   = authentik_application.proxy_app["${each.key}"].uuid
  group    = lookup(each.value, "groups", "admin") != "users" ? data.authentik_group.admins.id : data.authentik_group.users.id
  order    = 0
}

resource "authentik_outpost" "outpost" {
  name = "terrafrom outpost"
  protocol_providers = [for proxy in 
    authentik_provider_proxy.proxy_provider: proxy.id
  ]
  service_connection = authentik_service_connection_docker.local.id
  config = jsonencode({
    log_level = "info"
    docker_labels = {
      "traefik.enable": "true",
      "traefik.http.routers.sso-proxy.rule":"HostRegexp(`{subdomain:[a-z\\-]+}.${var.domain}`) && PathPrefix(`/outpost.goauthentik.io/`)",
      "traefik.http.routers.sso-proxy.tls":"true",
      "traefik.http.routers.sso-proxy.tls.certresolver":"xllb",
      "traefik.http.routers.sso-proxy.entrypoints":"websecure",
      "traefik.http.routers.sso-proxy.tls.domains[0].main":"${var.domain}",
      "traefik.http.routers.sso-proxy.tls.domains[0].sans":"*.${var.domain}",
      "traefik.http.services.sso-proxy.loadbalancer.server.port":"9000",
    }
    authentik_host = "http://authentik-server:9000/"
    docker_network = "homelab_default"
    container_image = null
    docker_map_ports = false
    authentik_host_browser = "https://sso.${var.domain}:${var.port}"
    object_naming_template =  "ak-outpost-%(name)s"
    authentik_host_insecure=  false
  }
  )
  

}

### simple application template
resource "authentik_application" "simple_app" {
  for_each           = local.simple_apps
  name               = each.value.name
  slug               = each.key
  group              = each.value.group
  policy_engine_mode = "all"
  meta_description   = each.value.desc
  meta_icon          = "/application-icons/${each.value.name}.png"
  meta_launch_url    = lookup(each.value, "url", "https://${each.key}.${var.domain}:${var.port}")
}

resource "authentik_policy_binding" "simple_policy_binding" {
  for_each = local.simple_apps
  target   = authentik_application.simple_app["${each.key}"].uuid
  group    = lookup(each.value, "groups", "admin") != "users" ? data.authentik_group.admins.id : data.authentik_group.users.id
  order    = 0
}