ActiveAdmin.register AutomatedResponse do
  menu label: "Automated Responses", priority: 4
  
  permit_params :alert_rule_id, :action_type, :target_service, :cooldown_period,
                :description, :active

  config.clear_action_items!

  index title: "Automated Responses" do
    selectable_column
    id_column
    column :alert_rule
    column :action_type
    column :target_service
    column :cooldown_period
    column :active
    actions
  end

  form do |f|
    f.inputs "Response Details" do
      f.input :alert_rule
      f.input :action_type, as: :select, collection: AutomatedResponse::ACTIONS
      f.input :target_service
      f.input :cooldown_period, hint: "Format: 10s, 1m, 1h"
      f.input :description
      f.input :active
    end
    f.actions
  end
end