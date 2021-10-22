client {
  host_volume "mysql" {
    path      = "/opt/mysql/data"
    read_only = false
  }
}
