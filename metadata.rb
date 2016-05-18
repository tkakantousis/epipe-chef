maintainer       "Jim Dowling"
maintainer_email "jdowling@kth.se"
name             "epipe"
license          "Apache v2.0"
description      "Installs/Configures a HopsFS to ElasticSearch connector"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.0"
source_url       "https://github.com/hopshadoop/epipe-chef"

%w{ ubuntu debian centos }.each do |os|
  supports os
end

depends 'java'

recipe "epipe::default", "Installs and configures Epipe Server"

attribute "epipe/user",
:description => "User to run Epipe server as",
:type => "string"


