class AutomatedResponse < ApplicationRecord
  belongs_to :alert_rule

  validates :action_type, presence: true
  validates :cooldown_period, presence: true, format: {
    with: /\A\d+[smh]\z/,
    message: "must be in format: 10s, 1m, 1h"
  }

  scope :active, -> { where(active: true) }

  def self.action_types
    %w[restart_service run_command send_notification]
  end

  def execute
    case action_type
    when 'restart_service'
      execute_service_restart
    when 'run_command'
      execute_command
    when 'send_notification'
      send_notification
    end
  end

  private

  def execute_service_restart
    return unless target_service.present?
    # Implementation for restarting service
    Rails.logger.info "Restarting service: #{target_service}"
    # system("systemctl restart #{target_service}")
  end

  def execute_command
    return unless command.present?
    # Implementation for running custom command
    Rails.logger.info "Running command: #{command}"
    # system(command)
  end

  def send_notification
    # Implementation for sending notification
    Rails.logger.info "Sending notification for alert rule: #{alert_rule.name}"
    # NotificationService.send_alert(alert_rule)
  end
end