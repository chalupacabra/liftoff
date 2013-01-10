name 'example'
description 'Example deploy recipe for use w/ simple deploy'
run_list 'role[base]', 'recipe[build-essential]', 
         'recipe[git]', 'recipe[apache2]', 
         'recipe[intu_simple_deploy_example]'

override_attributes(
  'apache' => {
    'default_site_enabled' => true
  }
)
