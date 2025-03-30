class TelegrafConfigGenerator
  def self.generate(config_object, config_content)
    return unless config_object.active?

    # Ensure directory exists before writing file
    config_dir = Rails.root.join("config/telegraf/conf.d")
    FileUtils.mkdir_p(config_dir) unless Dir.exist?(config_dir)

    config_type = config_object.class.name.underscore.split("_")[1] # Extract 'cpu' or 'memory'

    File.write(
      Rails.root.join("config/telegraf/conf.d/#{config_type}_#{config_object.id}.conf"),
      config_content
    )
  end
end
