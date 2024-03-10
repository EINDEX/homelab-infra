
variable "domain" {
  type = string
}


variable "port" {
  type = string
}


variable "synology_url" {
  type = string
}

variable "gitea_client_id" {
  type = string
}

variable "gitea_client_secret" {
  type = string
}

variable "strapi_client_id" {
  type = string
}

variable "strapi_client_secret" {
  type = string
}

variable "dsm_client_id" {
  type = string
}

variable "dsm_client_secret" {
  type = string
}

variable "penpot_client_id" {
  type = string
}

variable "penpot_client_secret" {
  type = string
}

variable "outline_client_id" {
  type = string
}

variable "outline_client_secret" {
  type = string
}


locals {
  applications = {
    sonarr = {
      name   = "Sonarr"
      desc   = "电视剧抓取"
      group  = "Media"
      type   = "proxy"
      groups = "users"
    }


    jproxy = {
      name  = "Jproxy"
      desc  = ""
      group = "Media"
      type  = "proxy"
    }
    hc = {
      name            = "HealthChecks"
      desc            = "Is Running?"
      group           = "Development"
      type            = "proxy"
      skip_path_regex = "/ping/.*\n/api/.*"
    }
    radarr = {
      name   = "Radarr"
      desc   = "电影抓取"
      group  = "Media"
      type   = "proxy"
      groups = "users"
    }
    lidarr = {
      name  = "Lidarr"
      desc  = "音乐抓取"
      group = "Media"
      type  = "proxy"
    }

    prowlarr = {
      name  = "Prowlarr"
      desc  = "种子中心"
      group = "Media"
      type  = "proxy"
    }
    qbt = {
      name  = "qBittorrent"
      desc  = "BT 下载器"
      group = "Media"
      type  = "proxy"
    }

    bazarr = {
      name  = "Bazarr"
      desc  = ""
      group = "Media"
      type  = "proxy"
    }

    overseerr = {
      name   = "Overseerr"
      desc   = "好片发现"
      group  = "Media"
      type   = "proxy"
      groups = "users"
    }

    fava = {
      name  = "Fava"
      desc  = "Finance"
      group = ""
      type  = "proxy"
    }

    traefik = {
      name  = "Traefik"
      desc  = "API Dashboard"
      group = "Development"
      type  = "proxy"
    }
    haos = {
      name            = "Home Assistant"
      desc            = ""
      group           = "Home Build"
      type            = "proxy"
      skip_path_regex = "^/api/.*"
    }
    code-server = {
      name  = "Code Server"
      desc  = ""
      group = "Development"
      type  = "proxy"
    }

    gpt-web = {
      name  = "GPT Web"
      desc  = ""
      group = ""
      type  = "proxy"
    }
    calibre = {
      name  = "Calibre"
      desc  = ""
      group = "Media"
      type  = "proxy"
    }

    auto-bangumi = {
      name  = "Auto Bangumi"
      desc  = ""
      group = "Media"
      type  = "proxy"
    }

    st = {
      name  = "Speed Test"
      desc  = ""
      group = "Tools"
      type  = "proxy"
    }

    # n8n = {
    #   name            = "n8n"
    #   desc            = ""
    #   group           = "Development"
    #   type            = "proxy"
    #   skip_path_regex = "^/webhook.*\n^/rest/oauth2-credential/"
    # }

    gitea = {
      name          = "Gitea"
      desc          = "代码仓库"
      group         = "Development"
      type          = "oauth"
      client_id     = var.gitea_client_id
      client_secret = var.gitea_client_secret
      redirect_uris = ["https://gitea.xllb.cc:8443/user/oauth2/Authentik/callback"]
    }

    # outline = {
    #   name          = "Outline"
    #   desc          = "Wiki"
    #   group         = "Development"
    #   type          = "oauth"
    #   groups = "users"
    #   client_id     = var.outline_client_id
    #   client_secret = var.outline_client_secret
    #   redirect_uris = ["https://outline.xllb.cc:8443/.*"]
    # }

    valut = {
      name   = "Bitwarden"
      desc   = "密码管理"
      group  = ""
      type   = "simple"
      groups = "users"
    }

    vault = {
      name   = "Bitwarden"
      desc   = "密码管理"
      group  = ""
      type   = "simple"
      groups = "users"
    }

    
    plex = {
      name   = "Plex"
      desc   = "多媒体中心"
      group  = "Media"
      type   = "simple"
      groups = "users"
    }

    yttl = {
      name   = "Synology"
      desc   = ""
      group  = ""
      type   = "simple"
      groups = "users"
      url    = "${local.synology_url}"
    }
    file = {
      name   = "Files"
      desc   = "群晖文件"
      group  = ""
      type   = "simple"
      groups = "users"
      url    = "${local.synology_url}/files"
    }
    backup = {
      name  = "Backup"
      desc  = "群晖备份"
      group = "Development"
      type  = "simple"
      url   = "${local.synology_url}/backup"
    }
    drive = {
      name   = "Synology Drive"
      desc   = "群晖同步盘"
      group  = ""
      type   = "simple"
      groups = "users"
      url    = "${local.synology_url}/drive"
    }
    moments = {
      name   = "Synology Photos"
      desc   = "照片库"
      group  = ""
      type   = "simple"
      groups = "users"
      url    = "${local.synology_url}/photos"
    }
  }
}


locals {
  proxy_apps = {
    for slug, app in local.applications : slug => app
    if app.type == "proxy"
  }
  simple_apps = {
    for slug, app in local.applications : slug => app
    if app.type == "simple"
  }
  oauth_apps = {
    for slug, app in local.applications : slug => app
    if app.type == "oauth"
  }
  domain       = "${var.domain}:${var.port}"
  synology_url = var.synology_url
}
