directory File.dirname(Chef::Config['log_location']) do
  owner 'root'
  group 'root'
  mode '0770'
end

file Chef::Config['log_location'].path do
  owner 'root'
  group 'root'
  mode '0600'
end
