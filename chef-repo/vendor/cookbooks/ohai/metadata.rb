name             'ohai'
maintainer       'Brett Weaver'
maintainer_email 'brett_weaver@intuit.com'
license          'Apache 2.0'
description      'Configures ohai'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

recipe 'ohai', 'Configures ohai'

%w{redhat centos}.each do |os|
  supports os
end
