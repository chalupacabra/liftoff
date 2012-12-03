environment_name            = node['intu_metadata']['app']['environment']
environment_secret          = node['intu_metadata']['app']['environment_secret']
node['environment_settings'] = EnvironmentSettings.new.load environment_name, environment_secret
