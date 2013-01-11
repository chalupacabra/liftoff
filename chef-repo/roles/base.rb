name 'base'
description 'Prepare Chef and download bootstrap metadata'
run_list 'recipe[intu_chef]', 'recipe[ohai]',
         'recipe[intu_metadata]', 'recipe[sudo]',
         'recipe[environment_settings]'

override_attributes(
  'authorization' => {
    'sudo' => {
      'sudoers_defaults' => ['!lecture', 'tty_tickets' , '!fqdn'],
      'passwordless'     => true,
      'users'            => ['ec2-user']
    }
  }
)
