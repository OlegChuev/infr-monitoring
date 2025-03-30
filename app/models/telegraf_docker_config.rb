class TelegrafDockerConfig < ApplicationRecord
  validates :interval, presence: true, format: {
    with: /\A\d+[smh]\z/,
    message: "must be in format: 10s, 1m, 1h"
  }
  validates :timeout, presence: true, format: {
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

  # Add remote host fields
  attribute :remote_hosts, :string
  attribute :use_ssh, :boolean, default: false
  attribute :ssh_user, :string

  # Update the callbacks
  after_save -> { TelegrafConfigService.generate(self, config) }
  after_destroy -> { TelegrafConfigService.remove(self) }

  private

  def config
    return unless active?

    # Parse container includes/excludes into arrays
    includes = container_name_include.to_s.split(",").map(&:strip).reject(&:empty?)
    excludes = container_name_exclude.to_s.split(",").map(&:strip).reject(&:empty?)

    # Basic Docker monitoring config
    docker_config = <<~TOML
      # Read metrics about docker containers
      [[inputs.docker]]
        ## Docker Endpoint
        endpoint = "unix:///var/run/docker.sock"
      #{'  '}
        ## Set to true to collect Swarm metrics
        gather_services = #{gather_services}
      #{'  '}
        ## Timeout for docker commands
        timeout = "#{timeout}"
      #{'  '}
        ## Whether to report per-device stats
        perdevice = #{perdevice}
      #{'  '}
        ## Whether to report total stats
        total = #{total}
      #{'  '}
        ## Containers to include and exclude (comma-separated)
        container_name_include = #{includes.empty? ? '[]' : includes.to_s.gsub('[', '["').gsub(']', '"]').gsub(', ', '", "')}
        container_name_exclude = #{excludes.empty? ? '[]' : excludes.to_s.gsub('[', '["').gsub(']', '"]').gsub(', ', '", "')}
      #{'  '}
        ## Collect metrics with this interval
        interval = "#{interval}"
    TOML

    # Add remote host monitoring if configured
    if remote_hosts.present?
      hosts = remote_hosts.split(",").map(&:strip)

      if use_ssh && ssh_user.present?
        # SSH-based monitoring
        hosts.each do |host|
          docker_config += <<~TOML

            # Remote Docker monitoring via SSH for #{host}
            [[inputs.exec]]
              commands = [
                "ssh #{ssh_user}@#{host} 'docker stats --no-stream --format \\"{{.Name}},{{.CPUPerc}},{{.MemUsage}},{{.MemPerc}},{{.NetIO}},{{.BlockIO}},{{.PIDs}}\\"'"
              ]
              timeout = "#{timeout}"
              interval = "#{interval}"
              data_format = "csv"
              csv_header_row_count = 0
              csv_column_names = ["container_name", "cpu_percent", "mem_usage", "mem_percent", "net_io", "block_io", "pids"]
              name_override = "docker_remote_#{host.gsub('.', '_')}"
            #{'  '}
              [inputs.exec.tags]
                host = "#{host}"
          TOML
        end
      else
        # HTTP-based monitoring (assumes Telegraf API endpoints on remote hosts)
        hosts.each do |host|
          docker_config += <<~TOML

            # Remote Docker monitoring via HTTP for #{host}
            [[inputs.http]]
              urls = ["http://#{host}:9273/metrics"]
              timeout = "#{timeout}"
              interval = "#{interval}"
              data_format = "prometheus"
            #{'  '}
              [inputs.http.tags]
                host = "#{host}"
          TOML
        end
      end
    end

    docker_config
  end
end
