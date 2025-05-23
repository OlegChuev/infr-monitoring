class TelegrafCpuConfig < ApplicationRecord
  include TelegrafConfigurable

  private

  def config
    return unless active?
    remote_hosts.active.map { |host| generate_host_config(host) }.join("\n")
  end

  def generate_host_config(host)
    command = "ssh #{host.username}@#{host.hostname} cat /proc/stat | grep cpu"
    command += " -p #{host.port}" if host.port.present?

    <<~TOML
    
      # Remote CPU monitoring via SSH for #{host.hostname}
      [[inputs.exec]]
        commands = [
          "#{command}"
        ]
        timeout = "5s"
        interval = "#{interval}"
        data_format = "value"
        data_type = "string"
        name_override = "cpu_remote_#{host.hostname.gsub('.', '_')}"
      
        [inputs.exec.tags]
          host = "#{host.hostname}"
          config_name = "#{name}"
    TOML
  end
end