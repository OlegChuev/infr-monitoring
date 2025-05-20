class InfluxdbService
  attr_reader :host, :port, :database

  def initialize
    @host = ENV["INFLUXDB_HOST"] || "influxdb"
    @port = ENV["INFLUXDB_PORT"] || 8086
    @database = ENV["INFLUXDB_BUCKET"] || "metrics"
    @user = ENV["INFLUXDB_USER"]
    @password = "your-super-secret-token"
    @connection_tested = false
  end

  def client
    @client ||= InfluxDB::Client.new(
      host: @host,
      port: @port,
      database: @database,
      username: @user,
      password: @password,
      retry: 3,
      retry_interval: 1
    )
  end

  def test_connection
    return @connection_tested if @connection_tested

    begin
      client.ping
      @connection_tested = true
    rescue => e
      Rails.logger.error("InfluxDB connection error: #{e.message}")
      @connection_tested = false
    end
  end

  def fetch_cpu_usage(host, time_range: "5m", group_by: "1m", limit: 1)
    query = build_query("mean(\"usage_idle\")", "cpu", host, time_range, group_by, limit)
    result = execute_query(query)

    return nil if result.empty?
    (100 - result.first["values"].first["mean"]).round(1)
  end

  def fetch_memory_usage(host, time_range: "5m", group_by: "1m", limit: 1)
    query = build_query("mean(\"used_percent\")", "mem", host, time_range, group_by, limit)
    result = execute_query(query)

    return nil if result.empty?
    result.first["values"].first["mean"].round(1)
  end

  def fetch_cpu_history(host, time_range: "1h", group_by: "5m")
    query = build_query("mean(\"usage_idle\")", "cpu", host, time_range, group_by)
    execute_query(query)
  end

  def fetch_memory_history(host, time_range: "1h", group_by: "5m")
    query = build_query("mean(\"used_percent\")", "mem", host, time_range, group_by)
    execute_query(query)
  end

  private

  def build_query(function, measurement, host, time_range, group_by, limit = nil)
    query = "SELECT #{function} FROM \"#{measurement}\" WHERE \"host\" = '#{host}' AND time > now() - #{time_range} GROUP BY time(#{group_by})"
    query += " LIMIT #{limit}" if limit
    query
  end

  def execute_query(query)
    test_connection
    client.query(query)
  rescue => e
    Rails.logger.error("InfluxDB query error: #{e.message} for query: #{query}")
    []
  end
end
