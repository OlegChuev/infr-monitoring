ActiveAdmin.register TelegrafCpuConfig do
  menu label: "CPU Monitoring Config"

  # Update permit_params to include remote host fields
  permit_params :description, :interval, :percpu, :totalcpu, :collect_cpu_time, :report_active,
                :active, :remote_hosts, :use_ssh, :ssh_user

  # Hide default actions
  config.clear_action_items!

  action_item :new, only: :index do
    link_to "Add CPU Monitoring Config", new_admin_telegraf_cpu_config_path
  end

  action_item :edit, only: :show do
    link_to "Edit CPU Monitoring Config", edit_admin_telegraf_cpu_config_path(resource)
  end

  action_item :delete, only: :show do
    link_to "Delete CPU Monitoring Config", admin_telegraf_cpu_config_path(resource),
            method: :delete,
            data: { confirm: "Are you sure you want to delete this CPU monitoring configuration?" }
  end

  # Update the form to include remote host fields
  form title: "CPU Monitoring Configuration" do |f|
    f.inputs "CPU Monitoring Configuration" do
      f.input :description
      f.input :interval,
              hint: "Format: 10s, 1m, 1h (s: seconds, m: minutes, h: hours)"
      f.input :percpu,
              hint: "Collect metrics for each CPU"
      f.input :totalcpu,
              hint: "Collect metrics for total CPU usage"
      f.input :collect_cpu_time,
              hint: "Collect CPU time metrics"
      f.input :report_active,
              hint: "Report CPU time spent in active state"
    end

    f.inputs "Remote Host Monitoring" do
      f.input :remote_hosts,
              hint: "Comma-separated list of remote hosts to monitor (e.g., 192.168.1.10,server2.example.com)"
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
  show title: "CPU Monitoring Details" do
    attributes_table do
      row :id
      row :description
      row :interval
      row :percpu
      row :totalcpu
      row :collect_cpu_time
      row :report_active
      row :remote_hosts
      row :use_ssh
      row :ssh_user
      row :active
      row :created_at
      row :updated_at
    end
  end
end
