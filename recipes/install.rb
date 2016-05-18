
package_url = "#{node.epipe.url}"
base_package_filename = File.basename(package_url)
cached_package_filename = "#{Chef::Config.file_cache_path}/#{base_package_filename}"

remote_file cached_package_filename do
  source package_url
  owner "root"
  mode "0644"
  action :create_if_missing
end

nn = private_recipe_ip("apache_hadoop", "nn") + ":#{node.apache_hadoop.nn.port}"

epipe_downloaded = "#{node.epipe.dir}/.epipe.extracted_#{node.epipe.version}"
# Extract Oozie
bash 'extract_epipe' do
        user "root"
        code <<-EOH
                tar -xf #{cached_package_filename} -C #{node.epipe.dir}
                chown -R #{node.epipe.user}:#{node.epipe.group} #{node.epipe.base_dir}
                cd #{node.epipe.base_dir}
                touch #{epipe_downloaded}
                chown #{node.epipe.user} #{node.epipe.dir}/.epipe.extracted_#{node.epipe.version}
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

# # Assume there is a mysql server running on the same host as the Oozie server
# private_ip = my_private_ip()

# template"#{node.epipe.home}/conf/epipe-site.xml" do
#   source "epipe-site.xml.erb"
#   owner node.epipe.user
#   group node.epipe.group
#   mode 0655
#   variables({ 
#            })
# end

