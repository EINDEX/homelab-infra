terraform {
  required_version = ">= 1.1"

  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = ">= 2022.4.1"
    }
  }
  experiments = [module_variable_optional_attrs]
}

provider "authentik" {
}