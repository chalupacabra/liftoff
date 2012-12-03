class EnvironmentSettings

  def load(app_environment, app_environment_secret)
    Chef::EncryptedDataBagItem.load 'environments',
                                    app_environment,
                                    app_environment_secret
  end

end
