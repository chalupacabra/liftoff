include_recipe 'ohai'

dir = directory '/etc/intu_metadata.d' do
  owner 'root'
  group 'root'
  mode 0700
end

dir.run_action :create

# only grab our 'app_' keys
app_vars = node.cfn.to_hash.select { |k, v| k =~ /app_/}

# convert arrays to csv
app_vars.each_pair do |k,v|
  app_vars[k] = v.join(',') if v.kind_of? Enumerable
end

# drop the app prefix
app_vars.keys.each do |key|
  app_vars[key.gsub('app_', '')] = app_vars[key]
  app_vars.delete key
end

app_file = template '/etc/intu_metadata.d/app' do
  owner 'root'
  group 'root'
  mode 0600
  source 'app.erb'
  variables :app => app_vars
end

app_file.run_action :create

node['intu_metadata'] = IntuMetadataSettingsLoader.new.load
