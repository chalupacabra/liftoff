name 'example'
description 'Example deploy recipe for use w/ simple deploy'
run_list 'role[base]', 'recipe[environment_settings]',
         'recipe[build-essential]', 'recipe[git]', 
         'recipe[apache2]', 'recipe[intu_simple_deploy_example]'