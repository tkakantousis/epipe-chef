maintainer       "Jim Dowling"
maintainer_email "jdowling@kth.se"
name             "epipe"
license          "Apache v2.0"
description      "Installs/Configures a HopsFS to ElasticSearch connector"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.1"
source_url       "https://github.com/hopshadoop/epipe-chef"

%w{ ubuntu debian centos }.each do |os|
  supports os
end

depends 'java'
depends 'ndb'
depends 'apache_hadoop'
depends 'hops'
depends 'elastic'

recipe "epipe::install", "Installs Epipe Server"
recipe "epipe::default", "configures Epipe Server"
recipe "epipe::purge", "Deletes the Epipe Server"

attribute "epipe/user",
          :description => "User to run Epipe server as",
          :type => "string"

attribute "epipe/group",
          :description => "Group to run Epipe server as",
          :type => "string"

attribute "epipe/version",
          :description => "Version of epipe to use",
          :type => "string"

attribute "epipe/url",
          :description => "Url to epipe binaries",
          :type => "string"

attribute "epipe/dir",
          :description => "Parent directory to install epipe in (/srv is default)",
          :type => "string"

attribute "epipe/pid_file",
          :description => "Change the location for the pid_file.",
          :type => "string"

