class HostService
  class << self
    def all_monitored_hosts
      hosts = []
      [ TelegrafCpuConfig, TelegrafMemoryConfig ].each do |model|
        model.all.each do |config|
          if config.remote_hosts.present?
            hosts += config.remote_hosts.split(",").map(&:strip)
          end
        end
      end

      hosts.uniq
    end
  end
end
