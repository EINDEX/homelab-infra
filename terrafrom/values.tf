
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

locals {
  applications = {
    sonarr = {
      name   = "Sonarr"
      desc   = "电视剧抓取"
      group  = "Media"
      type   = "proxy"
      groups = "users"
    }

    calibre-web = {
      name   = "Calibre Web"
      desc   = ""
      group  = "Media"
      type   = "proxy"
      groups = "users"
    }

    jackett = {
      name   = "Jackett"
      desc   = ""
      group  = "Media"
      type   = "proxy"
    }
    hc = {
      name   = "HealthChecks"
      desc   = "Is Running?"
      group  = "Development"
      type   = "proxy"
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
    memos = {
      name  = "Mem OS"
      desc  = "Note"
      group = ""
      type  = "proxy"
      skip_path_regex = "/api/.*"
    }
    bazarr = {
      name  = "Bazarr"
      desc  = ""
      group = "Media"
      type  = "proxy"
    }
    nastool = {
      name  = "NAS tools"
      desc  = ""
      group = "Media"
      type  = "proxy"
    }
    overseerr = {
      name  = "Overseerr"
      desc  = "好片发现"
      group = "Media"
      type  = "proxy"
      groups = "users"
    }
    router = {
      name  = "OpenWrt"
      desc  = "路由器"
      group = "Home Build"
      type  = "proxy"
    }
    fava = {
      name  = "Fava"
      desc  = "Finance"
      group = ""
      type  = "proxy"
    }

    traefik = {
      name  = "Traefik"
      desc  = "Development"
      group = ""
      type  = "proxy"
    }
    haos = {
      name  = "Home Assistant"
      desc  = ""
      group = "Home Build"
      type  = "proxy"
      skip_path_regex = "^/api/.*"
    }
    code-server = {
      name  = "Code Server"
      desc  = ""
      group = "Development"
      type  = "proxy"
    }

    n8n = {
      name  = "n8n"
      desc  = ""
      group = "Development"
      type  = "proxy"
      skip_path_regex = "^/webhook.*\n^/rest/oauth2-credential/"
    }

    rss = {
      name  = "FreshRss"
      desc  = "RSS"
      group = ""
      type  = "proxy"
      skip_path_regex = "/api/.*"
    }

    gitea = {
      name          = "Gitea"
      desc          = "代码仓库"
      group         = "Development"
      type          = "oauth"
      client_id     = var.gitea_client_id
      client_secret = var.gitea_client_secret
      redirect_uris = ["https://gitea.${var.domain}:${var.port}/user/oauth2/Authentik/callback"]
    }

    drone = {
      name          = "Drone"
      desc          = "Pipeline"
      group         = "Development"
      type          = "proxy"
      skip_path_regex = "^/api.*\n^/hook.*"
      
    }

    valut = {
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
      url = "${local.synology_url}"
    }
    file = {
      name   = "Files"
      desc   = "群晖文件"
      group  = ""
      type   = "simple"
      groups = "users"
      url = "${local.synology_url}/files"
    }
    backup = {
      name   = "Backup"
      desc   = "群晖备份"
      group  = "Development"
      type   = "simple"
      url = "${local.synology_url}/backup"
    }
    drive = {
      name   = "Synology Drive"
      desc   = "群晖同步盘"
      group  = ""
      type   = "simple"
      groups = "users"
      url = "${local.synology_url}/drive"
    }
    moments = {
      name   = "Synology Photos"
      desc   = "照片库"
      group  = ""
      type   = "simple"
      groups = "users"
      url = "${local.synology_url}/photos"
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
  domain = "${var.domain}:${var.port}"
  synology_url = "${var.synology_url}"
}