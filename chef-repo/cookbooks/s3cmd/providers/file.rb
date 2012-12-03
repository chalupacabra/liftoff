action :download do

  file_name = new_resource.file_name
  bucket = new_resource.bucket
  object_name = new_resource.object_name
  object_name.slice!(0) if object_name.start_with? '/'
  force = new_resource.force ? '--force' : ''

  execute "Downloading #{file_name} from s3" do
    command "s3cmd #{force} get s3://#{bucket}/#{object_name} #{file_name}"
  end

  file file_name do
    owner new_resource.owner
    group new_resource.group
    mode new_resource.mode
  end

end
