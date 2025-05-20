class MonitoringConfigService
  class << self
    def active_configurations_count
      TelegrafCpuConfig.where(active: true).count +
      TelegrafMemoryConfig.where(active: true).count
    end

    def configuration_files_count
      Dir.glob(Rails.root.join("config/telegraf/conf.d/*.conf")).count
    end

    def recent_configurations(type, limit = 5)
      case type.to_sym
      when :cpu
        TelegrafCpuConfig.order("created_at desc").limit(limit)
      when :memory
        TelegrafMemoryConfig.order("created_at desc").limit(limit)
      else
        []
      end
    end

    def all_config_models
      [ TelegrafCpuConfig, TelegrafMemoryConfig ]
    end
  end
end
