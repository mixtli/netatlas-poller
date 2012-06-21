Fabrication.configure do |config|
end

module NetAtlas
  module Model
    class Node < ::Sequel::Model; unrestrict_primary_key; end
  end
end