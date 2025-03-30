class TelegrafConfigRemover
  def self.remove(config_object)
    new(config_object).remove
  end

  def initialize(config_object)
    @config_object = config_object
    @config_type = config_object.class.name.demodulize.underscore.gsub("_config", "")
  end

  def remove
    file_path = Rails.root.join("config", "telegraf", "conf.d", "#{@config_type}_#{@config_object.id}.conf")
    File.delete(file_path) if File.exist?(file_path)
    Rails.logger.info "Removed Telegraf config file: #{file_path}"
    true
  rescue => e
    Rails.logger.error "Failed to remove Telegraf config file: #{e.message}"
    false
  end
end
