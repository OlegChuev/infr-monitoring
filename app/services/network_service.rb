class NetworkService
  require "socket"
  require "timeout"

  class << self
    def check_host_availability(host, port: 80, timeout: 1)
      return "Offline" if host.nil? || host.empty?

      host, port = host.split(":") if host.include?(":")

      begin
        Timeout.timeout(timeout) do
          TCPSocket.new(host, port).close
          "Online"
        end
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Timeout::Error
        "Offline"
      end
    end
  end
end
