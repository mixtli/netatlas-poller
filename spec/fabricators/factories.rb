Fabricator(:node, :from => NetAtlas::Model::Node)  do
  label 'foo'
  description  'bar'
  created_at Time.now
  updated_at Time.now
end