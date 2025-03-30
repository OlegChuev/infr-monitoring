class TelegrafConfigService
  def self.generate(config_object, config_content)
    new(config_object).generate(config_content)
  end
  
  def self.remove(config_object)
    new(config_object).remove
  end
  
  def initialize(config_object)
    @config_object = config_object
    @config_type = extract_config_type(config_object)
    @file_path = build_file_path
  end
  
  def generate(config_content)
    return unless @config_object.active?
    
    # Ensure directory exists before writing file
    ensure_directory_exists
    
    File.write(@file_path, config_content)
    Rails.logger.info "Generated Telegraf config file: #{@file_path}"
    true
  rescue => e
    Rails.logger.error "Failed to generate Telegraf config file: #{e.message}"
    false
  end
  
  def remove
    File.delete(@file_path) if File.exist?(@file_path)
    Rails.logger.info "Removed Telegraf config file: #{@file_path}"
    true
  rescue => e
    Rails.logger.error "Failed to remove Telegraf config file: #{e.message}"
    false
  end
  
  private
  
  def extract_config_type(config_object)
    config_object.class.name.demodulize.underscore.gsub('_config', '')
  end
  
  def build_file_path
    Rails.root.join('config', 'telegraf', 'conf.d', "#{@config_type}_#{@config_object.id}.conf")
  end
  
  def ensure_directory_exists
    config_dir = Rails.root.join('config', 'telegraf', 'conf.d')
    FileUtils.mkdir_p(config_dir) unless Dir.exist?(config_dir)
  end
end