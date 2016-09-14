nmy_ip = my_private_ip()
my_public_ip = my_public_ip()


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




case node.platform
when "ubuntu"
 if node.platform_version.to_f <= 14.04
   node.override.epipe.systemd = "false"
 end
end


service_name="epipe"

if node.epipe.systemd == "true"

  service service_name do
    provider Chef::Provider::Service::Systemd
    supports :restart => true, :stop => true, :start => true, :status => true
    action :nothing
  end

  case node.platform_family
  when "rhel"
    systemd_script = "/usr/lib/systemd/system/#{service_name}.service" 
  when "debian"
    systemd_script = "/lib/systemd/system/#{service_name}.service"
  end

  template systemd_script do
    source "#{service_name}.service.erb"
    owner "root"
    group "root"
    mode 0754
    notifies :enable, resources(:service => service_name)
    notifies :start, resources(:service => service_name), :immediately
  end

  apache_hadoop_start "reload_epipe_daemon" do
    action :systemd_reload
  end  

else #sysv

  service service_name do
    provider Chef::Provider::Service::Init::Debian
    supports :restart => true, :stop => true, :start => true, :status => true
    action :nothing
  end

  template "/etc/init.d/#{service_name}" do
    source "#{service_name}.erb"
    owner node.epipe.user
    group node.epipe.group
    mode 0754
    notifies :enable, resources(:service => service_name)
    notifies :restart, resources(:service => service_name), :immediately
  end

end


if node.kagent.enabled == "true" 
   kagent_config service_name do
     service service_name
     log_file "#{node.epipe.home}/epipe.log"
   end
end
