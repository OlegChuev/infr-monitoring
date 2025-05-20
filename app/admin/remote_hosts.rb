ActiveAdmin.register RemoteHost do
  menu priority: 1, label: "Remote Hosts"

  permit_params :hostname, :port, :description, :username, :active

  filter :hostname
  filter :description
  filter :status
  filter :active

  scope :all
  scope :active, default: true

  index do
    selectable_column
    id_column
    column :hostname
    column :username
    column :port
    column :status do |host|
      status_tag host.status || 'unknown'
    end
    column :active
    column :last_seen_at
    actions
  end

  show do
    attributes_table do
      row :hostname
      row :username
      row :port
      row :description
      row :status do |host|
        status_tag host.status || 'unknown'
      end
      row :active
      row :last_seen_at
      row :created_at
      row :updated_at
    end

    panel "CPU Monitoring Configurations" do
      table_for resource.telegraf_cpu_configs do
        column :name
        column :interval
        column :active
        column :actions do |config|
          link_to "View", admin_telegraf_cpu_config_path(config)
        end
      end
    end

    panel "RAM Monitoring Configurations" do
      table_for resource.telegraf_ram_configs do
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
    f.inputs "Host Details" do
      f.input :hostname
      f.input :username
      f.input :port
      f.input :description
      f.input :active
    end
    f.actions
  end

  sidebar "Host Status", only: :show do
    attributes_table do
      row :status do |host|
        status_tag host.status || 'unknown'
      end
      row :last_seen_at
    end
    div do
      button_to "Check Connection", check_connection_admin_remote_host_path(resource), method: :post, class: "button"
    end
  end

  member_action :check_connection, method: :post do
    # This would be implemented in a real application
    resource.update_status("checked")
    redirect_to admin_remote_host_path(resource), notice: "Connection check initiated"
  end
end