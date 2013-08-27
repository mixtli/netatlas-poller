# A sample Guardfile
# More info at https://github.com/guard/guard#readme

ENV['NETATLAS_ENVIRONMENT'] = 'test'

guard 'rspec', :version => 2, :cli => "--tty --color --fail-fast -b" do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end


#guard 'ctags-bundler' do
#  watch(%r{^(lib|spec/support)/.*\.rb$})  { ["lib", "spec/support"] }
#  watch('Gemfile.lock')
#end
