class AlertMonitoringWorker
  include Sidekiq::Worker
  sidekiq_options queue: :monitoring, retry: 3

  def perform
    AlertRule.where(active: true).find_each do |rule|
      check_and_process_alert(rule)
    end
  end

  private

  def check_and_process_alert(rule)
    metrics = MetricsService.new(rule.host)
    current_value = fetch_metric_value(metrics, rule.metric_type)

    return unless rule.evaluate_metric(current_value)

    rule.automated_responses.where(active: true).each do |response|
      next unless response.can_execute?

      ExecuteResponseWorker.perform_async(response.id, current_value)
    end
  end

  def fetch_metric_value(metrics, metric_type)
    case metric_type
    when 'cpu_usage'
      metrics.basic_metrics[:cpu_usage]
    when 'memory_usage'
      metrics.basic_metrics[:memory_usage]
    end
  end
end