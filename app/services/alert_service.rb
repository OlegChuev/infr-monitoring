class AlertService
  class << self
    def process_metric(metric_type, value, host_identifier)
      remote_host = RemoteHost.find_by(hostname: host_identifier)
      return unless remote_host

      applicable_rules(metric_type, remote_host).each do |rule|
        if rule_triggered?(rule, value)
          handle_alert(rule, value, remote_host)
        end
      end
    end

    private

    def applicable_rules(metric_type, remote_host)
      AlertRule.active.where(metric_type: metric_type)
    end

    def rule_triggered?(rule, value)
      case rule.operator
      when '>' then value > rule.threshold
      when '>=' then value >= rule.threshold
      when '<' then value < rule.threshold
      when '<=' then value <= rule.threshold
      when '==' then value == rule.threshold
      when '!=' then value != rule.threshold
      else false
      end
    end

    def handle_alert(rule, value, remote_host)
      Rails.logger.info "Alert triggered: #{rule.name} for host #{remote_host.hostname} (value: #{value})"
      
      # Execute automated responses
      rule.automated_responses.active.each do |response|
        response.execute
      end
    end
  end
end