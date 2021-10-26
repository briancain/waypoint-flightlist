client {
  host_volume "waypoint" {
    path      = "/opt/nomad/waypoint"
    read_only = false
  }
}

plugin "docker" {
  config {
    auth {
      config = "/home/brian/.docker/config.json"
    }
  }
}
