class MetricsService
  attr_reader :host

  def initialize(host)
    @host = host
    @influxdb = InfluxdbService.new
    @network = NetworkService
  end

  def basic_metrics
    begin
      cpu_usage = @influxdb.fetch_cpu_usage(@host)
      memory_usage = @influxdb.fetch_memory_usage(@host)
      host_status = @network.check_host_availability(@host)

      {
        cpu_usage: cpu_usage,
        memory_usage: memory_usage,
        status: host_status,
        error: nil
      }
    rescue => e
      Rails.logger.error("Error fetching metrics for host #{@host}: #{e.message}")
      {
        cpu_usage: nil,
        memory_usage: nil,
        status: "Error",
        error: e.message
      }
    end
  end

  def self.collect_all_hosts_metrics
    hosts = HostService.all_monitored_hosts

    hosts.map do |host|
      service = new(host)
      metrics = service.basic_metrics

      {
        host: host,
        metrics: metrics
      }
    end
  end
end
