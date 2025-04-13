ActiveAdmin.register AlertRule do
  menu label: "Alert Rules", priority: 3

  permit_params :metric_type, :operator, :threshold, :severity, :duration,
                :description, :active, :host,
                automated_responses_attributes: [:id, :action_type, :target_service, :cooldown_period, :description, :active, :_destroy]

  config.clear_action_items!

  action_item :new, only: :index do
    link_to "Add Alert Rule", new_admin_alert_rule_path
  end

  action_item :edit, only: :show do
    link_to "Edit Alert Rule", edit_admin_alert_rule_path(resource)
  end

  action_item :delete, only: :show do
    link_to "Delete Alert Rule", admin_alert_rule_path(resource),
            method: :delete,
            data: { confirm: "Are you sure you want to delete this alert rule?" }
  end

  index title: "Alert Rules" do
    selectable_column
    id_column
    column :metric_type
    column :operator
    column :threshold
    column :severity
    column :host
    column :active
    column "Responses" do |rule|
      rule.automated_responses.count
    end
    actions
  end

  form do |f|
    f.inputs "Alert Rule Details" do
      f.input :metric_type, as: :select, collection: AlertRule::METRIC_TYPES
      f.input :operator, as: :select, collection: AlertRule::OPERATORS
      f.input :threshold
      f.input :severity, as: :select, collection: AlertRule::SEVERITIES
      f.input :duration, hint: "Format: 10s, 1m, 1h"
      f.input :description
      f.input :host, hint: "Leave blank for all hosts"
    end

    f.inputs "Automated Responses" do
      f.has_many :automated_responses, allow_destroy: true, heading: false do |r|
        r.input :action_type, as: :select, collection: AutomatedResponse::ACTIONS
        r.input :target_service
        r.input :cooldown_period, hint: "Format: 10s, 1m, 1h"
        r.input :description
        r.input :active
      end
    end

    f.inputs "Status" do
      f.input :active
    end

    f.actions
  end

  show do
    attributes_table do
      row :id
      row :metric_type
      row :operator
      row :threshold
      row :severity
      row :duration
      row :description
      row :host
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
        column :description
      end
    end
  end
end