ActiveAdmin.register TelegrafRamConfig do
  menu priority: 3, label: "RAM Monitoring"

  permit_params :name, :interval, :description, :active, :alert_rule_id, remote_host_ids: []

  filter :name
  filter :interval
  filter :active
  filter :created_at

  index do
    selectable_column
    id_column
    column :name
    column :interval
    column :active
    column :alert_rule
    column :hosts do |config|
      config.remote_hosts.count
    end
    actions
  end

  show do
    attributes_table do
      row :name
      row :interval
      row :description
      row :active
      row :alert_rule
      row :created_at
      row :updated_at
    end

    panel "Assigned Hosts" do
      table_for telegraf_ram_config.remote_hosts do
        column :hostname
        column :description
        column :status do |host|
          status_tag host.status || 'unknown'
        end
        column :actions do |host|
          link_to "View Host", admin_remote_host_path(host)
        end
      end
    end
  end

  form do |f|
    f.inputs "RAM Configuration Details" do
      f.input :name
      f.input :interval, hint: "Format: 10s, 1m, 1h (s: seconds, m: minutes, h: hours)"
      f.input :description
      f.input :active
      f.input :alert_rule, collection: AlertRule.where(metric_type: 'memory_usage')
    end

    f.inputs "Monitored Hosts" do
      f.input :remote_hosts, as: :check_boxes,
              collection: RemoteHost.active.order(:hostname),
              member_label: ->(h) { "#{h.hostname} (#{h.description})" }
    end

    f.actions
  end

  sidebar "Configuration Status", only: :show do
    attributes_table do
      row :active
      row "Config File" do |config|
        path = Rails.root.join('config', 'telegraf', 'conf.d', "ram_#{config.id}.conf")
        if File.exist?(path)
          status_tag "Generated", class: "green"
        else
          status_tag "Missing", class: "red"
        end
      end
    end
    div do
      button_to "Regenerate Config", regenerate_config_admin_telegraf_ram_config_path(resource), method: :post, class: "button"
    end
  end

  member_action :regenerate_config, method: :post do
    TelegrafConfigService.generate(resource, resource.send(:config))
    redirect_to admin_telegraf_ram_config_path(resource), notice: "Configuration regenerated"
  end
end