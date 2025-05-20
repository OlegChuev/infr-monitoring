class TelegrafConfigService
  class << self
    def generate(config_object, config_content)
      new(config_object).generate(config_content)
    end

    def remove(config_object)
      new(config_object).remove
    end

    def reload_telegraf
      system('docker-compose restart telegraf')
    end
  end

  def initialize(config_object)
    @config_object = config_object
    @config_type = @config_object.config_type
    @file_path = build_file_path
  end

  def generate(config_content)
    return unless @config_object.active?

    ensure_directory_exists
    write_config(config_content)
    self.class.reload_telegraf
  end

  def remove
    return unless File.exist?(@file_path)
    
    File.delete(@file_path)
    self.class.reload_telegraf
  end

  private

  def write_config(content)
    File.write(@file_path, content)
    Rails.logger.info "Generated Telegraf config: #{@file_path}"
  rescue => e
    Rails.logger.error "Failed to generate config: #{e.message}"
    false
  end

  def build_file_path
    Rails.root.join('config', 'telegraf', 'conf.d', "#{@config_type}_#{@config_object.id}.conf")
  end

  def ensure_directory_exists
    config_dir = Rails.root.join('config', 'telegraf', 'conf.d')
    FileUtils.mkdir_p(config_dir) unless Dir.exist?(config_dir)
  end
end
