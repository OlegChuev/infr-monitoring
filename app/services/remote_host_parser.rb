class RemoteHostParser
  class << self
    def parse(host_entry)
      return nil if host_entry.blank?

      host, port = host_entry.split(":")
      port = port.to_i if port.present?
      port ||= 22 # Default to port 22 if not specified

      { host: host.strip, port: port }
    end

    def parse_hosts(hosts_string)
      return [] if hosts_string.blank?

      hosts_string.split(",").map(&:strip).map do |host_entry|
        parse(host_entry)
      end.compact
    end

    def generate_ssh_command(parsed_host, ssh_user, command)
      validate_host!(parsed_host)
      validate_command!(command)

      "ssh -p #{parsed_host[:port]} #{ssh_user}@#{parsed_host[:host]} '#{command}'"
    end

    def generate_http_url(parsed_host, path = "metrics", port = 9273)
      validate_host!(parsed_host)

      base_host = parsed_host[:host]
      custom_port = parsed_host[:port] != 22 ? parsed_host[:port] : port

      "http://#{base_host}:#{custom_port}/#{path}"
    end

    def validate_host!(parsed_host)
      raise ArgumentError, "Invalid host format" unless parsed_host.is_a?(Hash) && parsed_host[:host].present?
    end

    def validate_command!(command)
      raise ArgumentError, "Command cannot be empty" if command.blank?
      # raise ArgumentError, "Command contains unsafe characters" if command =~ /[;&|><$]/
    end

    def format_host_for_display(parsed_host)
      return "" unless parsed_host.is_a?(Hash) && parsed_host[:host].present?

      if parsed_host[:port] == 22
        parsed_host[:host]
      else
        "#{parsed_host[:host]}:#{parsed_host[:port]}"
      end
    end
  end
end
