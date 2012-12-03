class IntuMetadataSettingsLoader

  METADATA_ROOT = '/etc/intu_metadata.d'
  IGNORED_FILES = %w[. ..]

  def load
    parsed_data
  end

  private
  def parsed_data
    metadata_files.inject({}) do |result, file|
      result[metadata_key_name(file)] = parsed_file_data(file)
      result
    end
  end

  def metadata_files
    files = Dir.entries(METADATA_ROOT).select { |e| valid_file?(e) }
    files.collect { |f| File.expand_path(File.join(METADATA_ROOT, f)) }
  end

  def metadata_key_name(file)
    File.basename file
  end

  def parsed_file_data(file)
    file_content(file).split("\n").inject({}) do |result, item|
      k, v = item.split '=', 2
      result[k.downcase] = v
      result
    end
  end

  def file_content(file)
    IO.read file
  end

  def valid_file?(f)
    File.file?(File.expand_path(File.join(METADATA_ROOT, f))) && \
    !IGNORED_FILES.include?(f)
  end

end
