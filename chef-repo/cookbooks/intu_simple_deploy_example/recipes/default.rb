require 'uri'

include_recipe 's3cmd'

app_artifact_dir = File.join(Chef::Config[:file_cache_path], 'app')
app_dir = node['intu']['app']['root_path']

user node['intu']['app']['user']
group node['intu']['app']['group']

directory File.dirname(node['intu']['app']['root_path']) do
  owner node['intu']['app']['user']
  group node['intu']['app']['group']
  mode '0755'
  recursive true
end

directory app_dir do
  owner node['intu']['app']['user']
  group node['intu']['app']['group']
  mode '0755'
  recursive true
end

%w[shared shared/log].each do |dir|
  directory "#{node['intu']['app']['root_path']}/#{dir}" do
    owner node['intu']['app']['user']
    group node['intu']['app']['group']
    mode '0755'
  end
end

artifact_uri = URI.parse node['intu_metadata']['app']['artifact_url']

s3cmd_file "#{Chef::Config[:file_cache_path]}/app.tar.gz.gpg" do
  action :download
  bucket node['intu_metadata']['stack']['app_artifacts_bucket']
  object_name artifact_uri.path
  owner node['intu']['app']['user']
  group node['intu']['app']['group']
  mode '0600'
end

decryption_command = "gpg --batch --yes --cipher-algo AES256 --passphrase #{node['intu_metadata']['stack']['app_artifacts_url']}  --output #{Chef::Config[:file_cache_path]}/app.tar.gz #{Chef::Config[:file_cache_path]}/app.tar.gz.gpg"
execute decryption_command

directory app_artifact_dir do
  recursive true
  action :delete
end

directory app_artifact_dir

execute "Extract App Release" do
  command "tar xzf #{Chef::Config[:file_cache_path]}/app.tar.gz"
  cwd app_artifact_dir
end

directory File.join(app_artifact_dir, '.git') do
  recursive true
  action :delete
end

# TODO ugly hack
execute 'Create git repo so deploy is happy' do
  command 'git init; git add .; git commit -m "commit required for deploy to work.  it sucks."'
  cwd app_artifact_dir
  not_if do
    File.directory? File.join(app_artifact_dir, '.git')
  end
end

deploy node['intu']['app']['root_path'] do
  repo app_artifact_dir
  migrate false
  restart_command 'service httpd restart ; true'
  symlinks({})
  create_dirs_before_symlink []
  symlink_before_migrate({})
  symlinks 'log' => 'log'
  before_restart do
    link "/var/www/index.html" do
      to "#{release_path}/index.html"
    end

    file "/var/www/status.html" do
      content node['environment_settings']['id']
      owner "root"
      group "root"
      mode "0755"
      action :create
    end
  end
end

execute "/bin/chown -R #{node['intu']['app']['user']}:#{node['intu']['app']['group']} #{app_dir}"
