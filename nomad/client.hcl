consul {
  address = "192.168.0.158:8500"
}

client {
  # This will keep the container around on failure, nice for debugging while developing

  options {
    "docker.cleanup.image" = "false"
  }

  host_volume "waypoint" {
    path      = "/opt/nomad/waypoint"
    read_only = false
  }
}

plugin "docker" {
    cleanup {
      image = "false"
    }
  config {
    auth {
      config = "/home/brian/.docker/config.json"
    }
  }
}
