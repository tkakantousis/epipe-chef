nmy_ip = my_private_ip()
my_public_ip = my_public_ip()


nn = private_recipe_ip("hops", "nn") + ":#{node['hops']['nn']['port']}"
elastic = private_recipe_ip("elastic", "default") + ":#{node['elastic']['port']}"



# file "#{node['epipe']['base_dir']}/conf/epipe-site.xml" do
#   action :delete
# end

# private_ip = my_private_ip()

# template"#{node['epipe']['base_dir']}/conf/epipe-site.xml" do
#   source "epipe-site.xml.erb"
#   owner node['epipe']['user']
#   group node['epipe']['group']
#   mode 0655
#   variables({ 
#            })
# end

ndb_connectstring()

template"#{node['epipe']['base_dir']}/bin/start-epipe.sh" do
  source "start-epipe.sh.erb"
  owner node['epipe']['user']
  group node['epipe']['group']
  mode 0750
  variables({ :ndb_connectstring => node['ndb']['connectstring'],
               :database => "hops",
               :meta_database => "hopsworks",
               :elastic_addr => elastic,
            })
end

template"#{node['epipe']['base_dir']}/bin/reindex-epipe.sh" do
  source "reindex-epipe.sh.erb"
  owner node['epipe']['user']
  group node['epipe']['group']
  mode 0750
  variables({ :ndb_connectstring => node['ndb']['connectstring'],
               :database => "hops",
               :meta_database => "hopsworks",
               :elastic_addr => elastic,
            })
  only_if { node['elastic']['projects']['reindex'] == "true" }
end

template"#{node['epipe']['base_dir']}/bin/stop-epipe.sh" do
  source "stop-epipe.sh.erb"
  owner node['epipe']['user']
  group node['epipe']['group']
  mode 0750
end

#when upgrading, we want to reindex the newly created projects index
bash 'reindex epipe' do
  user node['epipe']['user']
  code <<-EOF
     #{node['epipe']['base_dir']}/bin/reindex-epipe.sh
  EOF
end


case node['platform']
when "ubuntu"
 if node['platform_version'].to_f <= 14.04
   node.override['epipe']['systemd'] = "false"
 end
end


service_name="epipe"

if node['epipe']['systemd'] == "true"

  service service_name do
    provider Chef::Provider::Service::Systemd
    supports :restart => true, :stop => true, :start => true, :status => true
    action :nothing
  end

  case node['platform_family']
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
if node['services']['enabled'] == "true"
    notifies :enable, resources(:service => service_name)
end
    notifies :restart, resources(:service => service_name)
  end

  kagent_config "#{service_name}" do
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
    owner node['epipe']['user']
    group node['epipe']['group']
    mode 0754
if node['services']['enabled'] == "true"
    notifies :enable, resources(:service => service_name)
end
    notifies :restart, resources(:service => service_name), :immediately
  end

end


if node['kagent']['enabled'] == "true" 
   kagent_config service_name do
     service "Hops"
     log_file "#{node['epipe']['base_dir']}/epipe.log"
   end
end
