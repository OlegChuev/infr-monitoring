class MonitoringService
  class << self
    def active_configurations_count
      TelegrafCpuConfig.where(active: true).count +
      TelegrafRamConfig.where(active: true).count
    end

    def configuration_files_count
      Dir.glob(Rails.root.join("config/telegraf/conf.d/*.conf")).count
    end

    def recent_configurations(type, limit = 5)
      case type.to_sym
      when :cpu
        TelegrafCpuConfig.order("created_at desc").limit(limit)
      when :ram
        TelegrafRamConfig.order("created_at desc").limit(limit)
      else
        []
      end
    end

    def all_config_models
      [TelegrafCpuConfig, TelegrafRamConfig]
    end
    
    def regenerate_all_configs
      all_config_models.each do |model|
        model.active.each do |config|
          TelegrafConfigService.generate(config, config.send(:config))
        end
      end
      TelegrafConfigService.reload_telegraf
    end
  end
end