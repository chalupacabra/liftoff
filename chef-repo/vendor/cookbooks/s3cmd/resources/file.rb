actions :download

attribute :file_name, :kind_of => String, :name_attribute => true
attribute :bucket, :kind_of => String
attribute :object_name, :kind_of => String
attribute :owner, :kind_of => String, :default => 'root'
attribute :group, :kind_of => String, :default => 'root'
attribute :mode, :kind_of => String, :default => '0600'
attribute :force, :kind_of => [ TrueClass, FalseClass ], :default => true
