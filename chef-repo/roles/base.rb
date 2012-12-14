name 'base'
description 'Prepare Chef and download bootstrap metadata'
run_list 'recipe[intu_chef]', 'recipe[ohai]',
         'recipe[intu_metadata]', 'recipe[sudo]',
         'recipe[environment_settings]'
