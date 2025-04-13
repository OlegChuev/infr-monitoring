class AlertMonitoringJob < ApplicationJob
  queue_as :default
  
  def perform
    AlertMonitoringService.check_alerts
  rescue => e
    Rails.logger.error("Alert monitoring failed: #{e.message}")
    raise e
  end
end
