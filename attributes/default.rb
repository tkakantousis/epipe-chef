include_attribute "kagent"
include_attribute "apache_hadoop"
include_attribute "hops"
include_attribute "ndb"
include_attribute "elastic"
include_attribute "elasticsearch"

default.epipe.version                  = "0.2.2"
default.epipe.user                     = node.apache_hadoop.hdfs.user
default.epipe.group                    = node.apache_hadoop.group
default.epipe.url                      = "#{node.download_url}/epipe/#{node.platform_family}/epipe-#{node.epipe.version}.tar.gz"
default.epipe.systemd                  = "true"
default.epipe.dir                      = "/srv"
default.epipe.base_dir                 = "/srv/epipe-" + "#{node.epipe.version}"
default.epipe.home                     = "/srv/epipe"
default.epipe.pid_file                 = "/tmp/epipe.pid"
