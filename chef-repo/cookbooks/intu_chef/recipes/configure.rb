%w[/opt/intu/admin /opt/intu/admin/bin].each do |dir|
  directory dir do
    owner 'root'
    group 'root'
    mode 0770
    recursive true
  end
end

link '/opt/intu/admin/bin/configure.sh' do
  to '/var/chef/script/configure.sh'
end

execute 'chmod -R 770 /opt/intu/admin'
execute 'chown -R root:root /opt/intu/admin'
