ActiveAdmin.register TelegrafDockerConfig do
  menu label: "Docker Monitoring Config"

  permit_params :description, :interval, :active, :container_name_include,
  :container_name_exclude, :perdevice, :total, :timeout, :gather_services,
  :remote_hosts, :use_ssh, :ssh_user

  # Hide default actions
  config.clear_action_items!

  action_item :new, only: :index do
    link_to "Add Docker Monitoring Config", new_admin_telegraf_docker_config_path
  end

  action_item :edit, only: :show do
    link_to "Edit Docker Monitoring Config", edit_admin_telegraf_docker_config_path(resource)
  end

  action_item :delete, only: :show do
    link_to "Delete Docker Monitoring Config", admin_telegraf_docker_config_path(resource),
            method: :delete,
            data: { confirm: "Are you sure you want to delete this Docker monitoring configuration?" }
  end

  index title: "Docker Monitoring Configurations" do
    selectable_column
    id_column
    column :description
    column :interval
    column :active
    column :created_at
    actions
  end

  filter :description
  filter :interval
  filter :active
  filter :created_at

  form title: "New Docker Monitoring Configuration" do |f|
    f.inputs "Docker Monitoring Configuration" do
      f.input :description
      f.input :interval,
              hint: "Format: 10s, 1m, 1h (s: seconds, m: minutes, h: hours)"
      f.input :timeout,
              hint: "Timeout for Docker commands (10s, 1m, etc.)"
      f.input :container_name_include,
              hint: "Comma-separated list of container names to include (leave empty for all)"
      f.input :container_name_exclude,
              hint: "Comma-separated list of container names to exclude"
      f.input :perdevice,
              hint: "Collect per-device metrics (CPU, network, block I/O)"
      f.input :total,
              hint: "Collect total metrics"
      f.input :gather_services,
              hint: "Collect Docker Swarm service metrics"
    end

    f.inputs "Remote Host Monitoring" do
      f.input :remote_hosts,
              hint: "Comma-separated list of remote hosts to monitor (e.g., 192.168.1.10:2222,server2.example.com)"
      f.input :use_ssh,
              hint: "Use SSH for remote monitoring (requires SSH keys setup)"
      f.input :ssh_user,
              hint: "SSH username for remote hosts"
    end

    f.inputs "Status" do
      f.input :active,
              hint: "Enable/disable this configuration"
    end

    f.actions
  end

  show title: "Docker Monitoring Details" do
    attributes_table do
      row :id
      row :description
      row :interval
      row :timeout
      row :container_name_include
      row :container_name_exclude
      row :perdevice
      row :total
      row :gather_services
      row :active
      row :created_at
      row :updated_at
    end
  end
end
