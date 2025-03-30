class TelegrafMemoryConfig < ApplicationRecord
  validates :interval, presence: true, format: {
    with: /\A\d+[smh]\z/,
    message: "must be in format: 10s, 1m, 1h"
  }

  # Add validations for SSH-based remote monitoring
  validates :remote_hosts, presence: true, if: :use_ssh?
  validates :ssh_user, presence: true, if: :use_ssh?

  # Add validations for remote monitoring
  validates :ssh_user, presence: true, if: -> { use_ssh? && remote_hosts.present? }
  validates :remote_hosts, format: {
    with: /\A[a-zA-Z0-9\-\.:,]+\z/,
    message: "must contain only hostnames, IPs, ports, and commas"
  }, allow_blank: true

  # Update the callbacks
  after_save -> { TelegrafConfigService.generate(self, config) }
  after_destroy -> { TelegrafConfigService.remove(self) }

  private

  def config
    return unless active?

    # Basic Memory monitoring config
    memory_config = <<~TOML
      [[inputs.mem]]
        interval = "#{interval}"
        swap_memory = #{swap_memory}
        platform_memory = #{platform_memory}
    TOML

    # Add remote host monitoring if configured
    if remote_hosts.present?
      hosts = remote_hosts.split(",").map(&:strip)

      if use_ssh && ssh_user.present?
        # SSH-based monitoring
        hosts.each do |host_entry|
          # Parse host and port (if specified)
          host, port = host_entry.split(":")
          port ||= 22 # Default to port 22 if not specified
          
          memory_config += <<~TOML

            # Remote Memory monitoring via SSH for #{host}
            [[inputs.exec]]
              commands = [
                "ssh -p #{port} #{ssh_user}@#{host} 'free -m'"
              ]
              timeout = "5s"
              interval = "#{interval}"
              data_format = "value"
              data_type = "string"
              name_override = "memory_remote_#{host.gsub('.', '_')}"
            #{'  '}
              [inputs.exec.tags]
                host = "#{host}"
          TOML
        end
      else
        # HTTP-based monitoring
        hosts.each do |host_entry|
          # For HTTP monitoring, we can use the host:port directly
          host = host_entry.split(":").first # Just extract the host part for the tag
          
          memory_config += <<~TOML

            # Remote Memory monitoring via HTTP for #{host_entry}
            [[inputs.http]]
              urls = ["http://#{host_entry}:9273/metrics"]
              timeout = "5s"
              interval = "#{interval}"
              data_format = "prometheus"
            #{'  '}
              [inputs.http.tags]
                host = "#{host}"
          TOML
        end
      end
    end

    memory_config
  end
end
