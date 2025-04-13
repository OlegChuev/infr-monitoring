class AutomatedResponse < ApplicationRecord
  belongs_to :alert_rule

  ACTIONS = %w[
    restart_service
  ].freeze

  validates :action_type, presence: true, inclusion: { in: ACTIONS }
  validates :target_service, presence: true
  validates :cooldown_period, presence: true, format: { with: /\A\d+[smh]\z/ }
  validates :description, presence: true

  def execute
    case action_type
    when 'restart_service'
      SystemService.restart_service(target_service)
    end
  end

  def last_execution
    ResponseExecution.where(automated_response: self)
                    .order(created_at: :desc)
                    .first
  end

  def can_execute?
    last_exec = last_execution
    return true unless last_exec

    time_since_last = Time.current - last_exec.created_at
    parsed_cooldown = parse_duration(cooldown_period)
    
    time_since_last > parsed_cooldown
  end

  private

  def parse_duration(duration)
    value = duration.to_i
    unit = duration[-1]
    
    case unit
    when 's' then value
    when 'm' then value * 60
    when 'h' then value * 3600
    else 
      raise "Invalid duration format: #{duration}"
    end
  end
end