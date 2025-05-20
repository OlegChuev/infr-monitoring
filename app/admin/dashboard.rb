ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel "System Overview" do
          div class: "dashboard-stats" do
            ul do
              li do
                span "Remote Hosts: "
                strong RemoteHost.count
              end
              li do
                span "Active Hosts: "
                strong RemoteHost.active.count
              end
              li do
                span "CPU Configurations: "
                strong TelegrafCpuConfig.count
              end
              li do
                span "RAM Configurations: "
                strong TelegrafRamConfig.count
              end
              li do
                span "Alert Rules: "
                strong AlertRule.count
              end
              li do
                span "Automated Responses: "
                strong AutomatedResponse.count
              end
            end
          end
        end
      end

      column do
        panel "Recent Activity" do
          span "Recent monitoring activity will be displayed here."
        end
      end
    end

    columns do
      column do
        panel "Recent CPU Configurations" do
          table_for MonitoringService.recent_configurations(:cpu) do
            column :name
            column :interval
            column :active
            column :created_at
            column :actions do |config|
              link_to "View", admin_telegraf_cpu_config_path(config)
            end
          end
        end
      end

      column do
        panel "Recent RAM Configurations" do
          table_for MonitoringService.recent_configurations(:ram) do
            column :name
            column :interval
            column :active
            column :created_at
            column :actions do |config|
              link_to "View", admin_telegraf_ram_config_path(config)
            end
          end
        end
      end
    end
  end

  page_action :regenerate_all_configs, method: :post do
    MonitoringService.regenerate_all_configs
    redirect_to admin_dashboard_path, notice: "All configurations regenerated"
  end

  page_action :restart_telegraf, method: :post do
    TelegrafConfigService.reload_telegraf
    redirect_to admin_dashboard_path, notice: "Telegraf service restarted"
  end
end
