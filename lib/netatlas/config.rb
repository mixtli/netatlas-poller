require 'yaml'
require 'logger'
NETATLAS_CONFIG_DIR = ENV['NETATLAS_CONFIG_DIR'] || "/etc/netatlas"
NETATLAS_ENVIRONMENT = ENV['NETATLAS_ENVIRONMENT'] || "development"
CONFIG = YAML.load(File.open(NETATLAS_CONFIG_DIR + "/netatlas.yml"))[NETATLAS_ENVIRONMENT]


logfile = NETATLAS_ENVIRONMENT == "test" ? STDOUT : File.open(CONFIG['logfile'], File::WRONLY | File::APPEND | File::CREAT)
$log = Logger.new(logfile)
$log.level = eval "Logger::#{CONFIG['loglevel'].upcase}"

#$log.info "ENVIRONMENT = #{NETATLAS_ENVIRONMENT}"
#$log.info "CONFIG = = #{CONFIG.inspect}"

