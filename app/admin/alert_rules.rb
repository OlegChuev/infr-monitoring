ActiveAdmin.register AlertRule do
  menu priority: 4, label: "Alert Rules"

  permit_params :name, :metric_type, :operator, :threshold, :severity, :duration, :description, :active

  filter :name
  filter :metric_type
  filter :severity
  filter :active
  filter :created_at

  index do
    selectable_column
    id_column
    column :name
    column :metric_type
    column :operator
    column :threshold
    column :severity do |rule|
      status_tag rule.severity
    end
    column :duration
    column :active
    actions
  end

  show do
    attributes_table do
      row :name
      row :metric_type
      row :operator
      row :threshold
      row :severity do |rule|
        status_tag rule.severity
      end
      row :duration
      row :description
      row :active
      row :created_at
      row :updated_at
    end

    panel "Automated Responses" do
      table_for alert_rule.automated_responses do
        column :action_type
        column :target_service
        column :cooldown_period
        column :active
        column :actions do |response|
          link_to "View", admin_automated_response_path(response)
        end
      end
    end

    panel "Associated CPU Configurations" do
      table_for alert_rule.telegraf_cpu_configs do
        column :name
        column :interval
        column :active
        column :actions do |config|
          link_to "View", admin_telegraf_cpu_config_path(config)
        end
      end
    end

    panel "Associated RAM Configurations" do
      table_for alert_rule.telegraf_ram_configs do
        column :name
        column :interval
        column :active
        column :actions do |config|
          link_to "View", admin_telegraf_ram_config_path(config)
        end
      end
    end
  end

  form do |f|
    f.inputs "Alert Rule Details" do
      f.input :name
      f.input :metric_type, as: :select, collection: AlertRule.metric_types
      f.input :operator, as: :select, collection: AlertRule.operators
      f.input :threshold
      f.input :severity, as: :select, collection: AlertRule.severities
      f.input :duration, hint: "Format: 10s, 1m, 1h (s: seconds, m: minutes, h: hours)"
      f.input :description
      f.input :active
    end
    f.actions
  end

  sidebar "Add Response", only: :show do
    render partial: 'admin/alert_rules/add_response_form', locals: { alert_rule: resource }
  end
end