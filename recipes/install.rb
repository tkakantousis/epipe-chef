
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

nn = private_recipe_ip("apache_hadoop", "nn") + ":#{node.apache_hadoop.nn.port}"
elastic = private_recipe_ip("elastic", "default") + ":#{node.elastic.port}"

epipe_downloaded = "#{node.epipe.base_dir}/.epipe.extracted_#{node.epipe.version}"
# Extract epipe
bash 'extract_epipe' do
        user "root"
        code <<-EOH
                tar -xf #{cached_package_filename} -C #{node.epipe.dir}
                chown -R #{node.epipe.user}:#{node.epipe.group} #{node.epipe.base_dir}
                cd #{node.epipe.base_dir}
                touch #{epipe_downloaded}
                chown #{node.epipe.user} #{epipe_downloaded}
        EOH
     not_if { ::File.exists?( epipe_downloaded ) }
end

file node.epipe.home do
  action :delete
  force_unlink true  
end

link node.epipe.home do
  owner node.epipe.user
  group node.epipe.group
  to node.epipe.base_dir
end


# file "#{node.epipe.home}/conf/epipe-site.xml" do
#   action :delete
# end

# private_ip = my_private_ip()

# template"#{node.epipe.home}/conf/epipe-site.xml" do
#   source "epipe-site.xml.erb"
#   owner node.epipe.user
#   group node.epipe.group
#   mode 0655
#   variables({ 
#            })
# end

ndb_connectstring()

template"#{node.epipe.home}/bin/start-epipe.sh" do
  source "start-epipe.sh.erb"
  owner node.epipe.user
  group node.epipe.group
  mode 0750
   variables({ :ndb_connectstring => node.ndb.connectstring,
               :database => "hops",
               :meta_database => "hopsworks",
               :elastic_addr => elastic,
            })
end

template"#{node.epipe.home}/bin/stop-epipe.sh" do
  source "stop-epipe.sh.erb"
  owner node.epipe.user
  group node.epipe.group
  mode 0750
end


