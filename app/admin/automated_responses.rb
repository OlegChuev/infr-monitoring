ActiveAdmin.register AutomatedResponse do
  menu priority: 5, label: "Automated Responses"

  permit_params :alert_rule_id, :action_type, :target_service, :command, :cooldown_period, :description, :active

  filter :action_type
  filter :target_service
  filter :active
  filter :created_at

  index do
    selectable_column
    id_column
    column :alert_rule
    column :action_type
    column :target_service
    column :cooldown_period
    column :active
    actions
  end

  show do
    attributes_table do
      row :alert_rule
      row :action_type
      row :target_service
      row :command
      row :cooldown_period
      row :description
      row :active
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs "Automated Response Details" do
      f.input :alert_rule
      f.input :action_type, as: :select, collection: AutomatedResponse.action_types
      f.input :target_service, hint: "Required for restart_service action type"
      f.input :command, hint: "Required for run_command action type"
      f.input :cooldown_period, hint: "Format: 10s, 1m, 1h (s: seconds, m: minutes, h: hours)"
      f.input :description
      f.input :active
    end
    f.actions
  end

  sidebar "Test Response", only: :show do
    div do
      button_to "Test Response", test_response_admin_automated_response_path(resource), method: :post, class: "button", data: { confirm: "This will execute the response action. Are you sure?" }
    end
  end

  member_action :test_response, method: :post do
    # This would be implemented in a real application
    # resource.execute
    redirect_to admin_automated_response_path(resource), notice: "Response test initiated"
  end
end