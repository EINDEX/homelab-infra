data "authentik_flow" "ldap_default_authentication_flow" {
  slug = "default-authentication-flow"
}

data "authentik_flow" "default_source_authentication" {
  slug = "default-source-authentication"
}

resource "authentik_provider_ldap" "ldap" {
  name      = "Ldap Center"
  base_dn   = "dc=ldap,dc=goauthentik,dc=io"
  bind_flow = data.authentik_flow.ldap_default_authentication_flow.id
}

data "authentik_property_mapping_ldap" "ldap-user" {
  managed_list = [
    "goauthentik.io/sources/ldap/openldap-cn",
    "goauthentik.io/sources/ldap/openldap-uid",
    "goauthentik.io/sources/ldap/default-mail",
    "goauthentik.io/sources/ldap/default-name"
  ]
}

data "authentik_property_mapping_ldap" "ldap-group" {
  managed_list = [
    "goauthentik.io/sources/ldap/openldap-cn",
  ]
}


variable "ldap_url" {
  type = string
}

variable "ldap_bind_cn" {
  type = string
}

variable "ldap_bind_password" {
  type = string
}

resource "authentik_source_ldap" "YTTL" {
  name = "YTTL Ldap"
  slug = "yttl-ldap"

  server_uri              = var.ldap_url
  bind_cn                 = var.ldap_bind_cn
  bind_password           = var.ldap_bind_password
  base_dn                 = "dc=yttl"
  property_mappings       = data.authentik_property_mapping_ldap.ldap-user.ids
  object_uniqueness_field = "entryUUID"
  property_mappings_group = data.authentik_property_mapping_ldap.ldap-group.ids
  group_object_filter     = "(objectClass=posixGroup)"
  start_tls               = false
}


variable "plex_client_id" {
  type = string
}


variable "plex_token" {
  type = string
}



resource "authentik_source_plex" "plex" {
  name                = "Plex"
  slug                = "plex"
  authentication_flow = data.authentik_flow.default_source_authentication.id
  enrollment_flow     = data.authentik_flow.default_source_authentication.id
  client_id           = var.plex_client_id
  plex_token          = var.plex_token
  allow_friends       = true
  user_matching_mode  = "email_link"
}


variable "github_consume_key" {
  type = string
}

variable "github_consume_secret" {
  type = string
}

resource "authentik_source_oauth" "github" {
  name                = "Github"
  slug                = "github"
  authentication_flow = data.authentik_flow.default_source_authentication.id
  enrollment_flow     = data.authentik_flow.default_source_authentication.id
  user_matching_mode  = "username_deny"
  policy_engine_mode  = "any"
  provider_type       = "github"
  consumer_key        = var.github_consume_key
  consumer_secret     = var.github_consume_secret
  access_token_url    = "https://github.com/login/oauth/access_token"
  authorization_url   = "https://github.com/login/oauth/authorize"
  profile_url         = "https://api.github.com/user"
}