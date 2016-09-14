
user node.epipe.user do
  supports :manage_home => true
  home "/home/#{node.epipe.user}"
  action :create
  system true
  shell "/bin/bash"
  not_if "getent passwd #{node.epipe.user}"
end

group node.epipe.group do
  action :modify
  members ["#{node.epipe.user}"]
  append true
end


include_recipe "java"

package_url = "#{node.epipe.url}"
base_package_filename = File.basename(package_url)
cached_package_filename = "/tmp/#{base_package_filename}"

remote_file cached_package_filename do
  source package_url
  owner "root"
  mode "0644"
  action :create_if_missing
end


