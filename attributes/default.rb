include_attribute "kagent"
include_attribute "hops"
include_attribute "hops"
include_attribute "ndb"
include_attribute "elastic"
include_attribute "elasticsearch"

default.epipe.version                  = "0.4.0"
default.epipe.user                     = node.hops.hdfs.user
default.epipe.group                    = node.hops.group
default.epipe.url                      = "#{node.download_url}/epipe/#{node.platform_family}/epipe-#{node.epipe.version}.tar.gz"
default.epipe.systemd                  = "true"
default.epipe.dir                      = "/srv"
default.epipe.home                     = node.epipe.dir + "/epipe-" + "#{node.epipe.version}"
default.epipe.base_dir                 = "#{node.epipe.dir}/epipe"
default.epipe.pid_file                 = "/tmp/epipe.pid"
