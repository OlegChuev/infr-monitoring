class HostService
  class << self
    def all_monitored_hosts
      MonitoredHost.active
    end

    def available_hosts
      MonitoredHost.active.available
    end

    def update_all_statuses
      MonitoredHost.active.find_each do |host|
        host.update_status
      end
    end

    def check_all_alerts
      MonitoredHost.active.find_each do |host|
        CheckHostAlertsWorker.perform_async(host.id)
      end
    end

    def host_metrics(host_id)
      host = MonitoredHost.find(host_id)
      host.metrics
    rescue ActiveRecord::RecordNotFound
      { error: "Host not found" }
    end
  end
end
