maintainer       "Intuit Inc"
maintainer_email "brett_weaver@intuit.com"
license          "All rights reserved"
description      "Installs Git Client"
version          "0.1.0"

%w{ redhat }.each do |os|
  supports os
end
