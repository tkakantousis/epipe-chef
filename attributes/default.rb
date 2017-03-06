include_attribute "kagent"
include_attribute "apache_hadoop"
include_attribute "hops"
include_attribute "ndb"
include_attribute "elastic"
include_attribute "elasticsearch"

default.epipe.version                  = "0.4.0"
default.epipe.user                     = node.apache_hadoop.hdfs.user
default.epipe.group                    = node.apache_hadoop.group
default.epipe.url                      = "#{node.download_url}/epipe/#{node.platform_family}/epipe-#{node.epipe.version}.tar.gz"
default.epipe.systemd                  = "true"
default.epipe.dir                      = node.install.dir.empty? ? node.install.dir : "/srv"
default.epipe.home                     = node.epipe.dir + "/epipe-" + "#{node.epipe.version}"
default.epipe.base_dir                 = "#{node.epipe.dir}/epipe"
default.epipe.pid_file                 = "/tmp/epipe.pid"
