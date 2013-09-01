filename = File.dirname(__FILE__) + "/../../config/netatlas.yml"
env = ENV['NETATLAS_ENV'] || 'production'
NETATLAS_CONFIG = HashWithIndifferentAccess.new(YAML.load_file(filename)[env])

$log = Logger.new("/tmp/netatlas.log")

NetAtlas.setup(:url => NETATLAS_CONFIG[:netatlas_url], :user => NETATLAS_CONFIG[:netatlas_user], :password => NETATLAS_CONFIG[:netatlas_password], :logger => $log)


