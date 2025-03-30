ActiveAdmin.register TelegrafMemoryConfig do
  menu label: "Memory Monitoring Config"

  # Update permit_params to include remote host fields
  permit_params :description, :interval, :swap_memory, :platform_memory, :active,
                :remote_hosts, :use_ssh, :ssh_user

  # Hide default actions
  config.clear_action_items!

  # Update the page title
  config.batch_actions = true
  config.clear_action_items!

  action_item :new, only: :index do
    link_to "Add RAM Monitoring Config", new_admin_telegraf_memory_config_path
  end

  action_item :edit, only: :show do
    link_to "Edit RAM Monitoring Config", edit_admin_telegraf_memory_config_path(resource)
  end

  action_item :delete, only: :show do
    link_to "Delete RAM Monitoring Config", admin_telegraf_memory_config_path(resource),
            method: :delete,
            data: { confirm: "Are you sure you want to delete this RAM monitoring configuration?" }
  end

  index title: "RAM Monitoring Configurations" do
    selectable_column
    id_column
    column :description
    column :interval
    column :active

    actions
  end

  filter :description
  filter :interval
  filter :active

  form title: "New RAM" do |f|
    f.inputs "RAM Monitoring Configuration" do
      f.input :description
      f.input :interval,
              hint: "Format: 10s, 1m, 1h (s: seconds, m: minutes, h: hours)"
      f.input :swap_memory,
              hint: "Include swap memory metrics"
      f.input :platform_memory,
              hint: "Include platform-specific memory metrics"
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

  # Update the show view to display remote host information
  show title: "RAM Monitoring Details" do
    attributes_table do
      row :id
      row :description
      row :interval
      row :swap_memory
      row :platform_memory
      row :remote_hosts
      row :use_ssh
      row :ssh_user
      row :active
    end
  end
end
