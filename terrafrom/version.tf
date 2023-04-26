terraform {
  required_version = ">= 1.3"

  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = ">= 2023.4.0"
    }
  }
}

provider "authentik" {
}