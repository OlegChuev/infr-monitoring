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
  validates :remote_hosts, format: { with: /\A[a-zA-Z0-9\-\.:,]+\z/, message: "must contain only hostnames, IPs, ports, and commas" }, allow_blank: true

  after_save -> { TelegrafConfigService.generate(self, config) }
  after_destroy -> { TelegrafConfigService.remove(self) }

  private

  def config
    return unless active?

    # Basic memory monitoring config
    memory_config = <<~TOML
      [[inputs.mem]]
        interval = "#{interval}"
    TOML

    # Add remote host monitoring if configured
    if remote_hosts.present?
      parsed_hosts = RemoteHostParser.parse_hosts(remote_hosts)

      if use_ssh && ssh_user.present?
        # SSH-based monitoring
        parsed_hosts.each do |parsed_host|
          command = RemoteHostParser.generate_ssh_command(parsed_host, ssh_user, "cat /proc/meminfo")
          host_display = RemoteHostParser.format_host_for_display(parsed_host)

          memory_config += <<~TOML

            # Remote memory monitoring via SSH for #{host_display}
            [[inputs.exec]]
              commands = [
                "#{command}"
              ]
              timeout = "5s"
              interval = "#{interval}"
              data_format = "value"
              data_type = "string"
              name_override = "memory_remote_#{parsed_host[:host].gsub('.', '_')}"
            #{'  '}
              [inputs.exec.tags]
                host = "#{parsed_host[:host]}"
          TOML
        end
      end
    end

    memory_config
  end
end
