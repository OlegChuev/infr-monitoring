class TelegrafCpuConfig < ApplicationRecord
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
    with: /\A[a-zA-Z0-9\-\.,]+\z/,
    message: "must contain only hostnames, IPs, and commas"
  }, allow_blank: true

  after_save -> { TelegrafConfigGenerator.generate(self, config) }
  after_destroy -> { TelegrafConfigRemover.remove(self) }

  private

  def config
    return unless active?

    # Basic CPU monitoring config
    cpu_config = <<~TOML
      [[inputs.cpu]]
        percpu = #{percpu}
        totalcpu = #{totalcpu}
        collect_cpu_time = #{collect_cpu_time}
        report_active = #{report_active}
        interval = "#{interval}"
    TOML

    # Add remote host monitoring if configured
    if remote_hosts.present?
      hosts = remote_hosts.split(",").map(&:strip)

      if use_ssh && ssh_user.present?
        # SSH-based monitoring
        hosts.each do |host|
          cpu_config += <<~TOML

            # Remote CPU monitoring via SSH for #{host}
            [[inputs.exec]]
              commands = [
                "ssh #{ssh_user}@#{host} 'cat /proc/stat | grep cpu'"
              ]
              timeout = "5s"
              interval = "#{interval}"
              data_format = "value"
              data_type = "string"
              name_override = "cpu_remote_#{host.gsub('.', '_')}"
            #{'  '}
              [inputs.exec.tags]
                host = "#{host}"
          TOML
        end
      else
        # HTTP-based monitoring
        hosts.each do |host|
          cpu_config += <<~TOML

            # Remote CPU monitoring via HTTP for #{host}
            [[inputs.http]]
              urls = ["http://#{host}:9273/metrics"]
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

    cpu_config
  end
end
