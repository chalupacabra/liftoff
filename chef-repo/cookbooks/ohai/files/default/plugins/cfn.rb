class CfnMetadataLoader

  IGNORED_METADATA_KEYS = [ 'AWS::CloudFormation::Init',
                            'AWS::CloudFormation::Authentication' ]

  def sanitized_metadata
    raw_cfn_metadata.reject { |k,v| IGNORED_METADATA_KEYS.include? k }
  end

  private
  def raw_cfn_metadata
    output = `#{cfn_metadata_command}`
    raise RuntimeError 'Unable to get cloud formation metadata' unless $?.success?
    JSON.parse output
  end

  def cfn_metadata_command
    cmd = '/opt/aws/bin/cfn-get-metadata '
    cmd << "-s #{stack_name} "
    cmd << "-r #{resource_name} "
    cmd << "--region #{region} "
    cmd << "--access-key #{access_key} "
    cmd << "--secret-key #{secret_key}"
  end

  def stack_name
    get_metadata_value 'stack', 'NAME'
  end

  def region
    get_metadata_value 'stack', 'REGION'
  end

  def resource_name
    get_metadata_value 'stack', 'RESOURCE_NAME'
  end

  def access_key
    get_metadata_value 'instance_user', 'ACCESS_KEY'
  end

  def secret_key
    get_metadata_value 'instance_user', 'SECRET_KEY'
  end

  def metadata_location
    '/etc/intu_metadata.d'
  end

  def get_metadata_value(file_name, key)
    parse_metadata_file(file_name).split("\n").each do |l|
      k, v = l.split '=', 2
      return v.strip if k == key
    end

    nil
  end

  def parse_metadata_file(file_name)
    IO.read File.join(metadata_location, file_name)
  end

end

provides 'cfn'

cfn Mash.from_hash(CfnMetadataLoader.new.sanitized_metadata)
