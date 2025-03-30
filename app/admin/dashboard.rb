ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: "Dashboard"

  page_action :restart_telegraf, method: :post do
    result = SystemService.restart_service("telegraf")

    if result[:success]
      redirect_to admin_dashboard_path, notice: result[:message]
    else
      redirect_to admin_dashboard_path, alert: result[:message]
    end
  end

  page_action :restart_influxdb, method: :post do
    result = SystemService.restart_service("influxdb")

    if result[:success]
      redirect_to admin_dashboard_path, notice: result[:message]
    else
      redirect_to admin_dashboard_path, alert: result[:message]
    end
  end

  content title: "Infrastructure Monitoring Dashboard" do
    def usage_panel(metric, title)
      if metric
        div class: "resource-usage" do
          div class: "usage-label" do
            span title
            span "#{metric}%"
          end
          div class: "usage-bar-container" do
            usage_class = metric < 50 ? "usage-low" : (metric < 80 ? "usage-medium" : "usage-high")
            div class: "usage-bar #{usage_class}", style: "width: #{metric}%"
          end
        end
      else
        div class: "resource-usage" do
          div class: "usage-label" do
            span title
            span "N/A"
          end
          div class: "usage-bar-container" do
            div class: "usage-bar usage-unknown", style: "width: 100%"
          end
        end
      end
    end

    # System Overview Section
    panel "System Overview", class: "system-overview-panel" do
      div class: "metric-cards-container" do
        div class: "metric-card" do
          div(class: "metric-title") { "Active Configurations" }
          div(class: "metric-value") { MonitoringConfigService.active_configurations_count }
        end

        div class: "metric-card" do
          div(class: "metric-title") { "Monitored Hosts" }
          div(class: "metric-value") { HostService.all_monitored_hosts.count }
        end

        div class: "metric-card" do
          div(class: "metric-title") { "Configuration Files" }
          div(class: "metric-value") { MonitoringConfigService.configuration_files_count }
        end

        div class: "metric-card" do
          div(class: "metric-title") { "System Status" }
          div class: "metric-value" do
            status = SystemService.system_status
            status_class = status[:healthy] ? "status-ok" : "status-error"
            span status[:healthy] ? "Healthy" : "Issues Detected", class: status_class
          end
        end
      end
    end

    columns do
      column do
        panel "Monitoring Configuration Status", class: "interactive-panel" do
          tabs do
            tab "CPU Monitoring" do
              configs = MonitoringConfigService.recent_configurations(:cpu)

              if configs.any?
                table_for configs do
                  column("Description") { |config| config.description }
                  column("Interval") { |config| config.interval }
                  column("Status") { |config| status_tag(config.active? ? "Active" : "Inactive", class: config.active? ? "status-ok" : "status-error") }

                  column("Actions") do |config|
                    span do
                      [
                        link_to("View", admin_telegraf_cpu_config_path(config), class: "table-action"),
                        link_to("Edit", edit_admin_telegraf_cpu_config_path(config), class: "table-action")
                      ].join.html_safe
                    end
                  end
                end

                div class: "panel-footer" do
                  link_to "View All CPU Configurations", admin_telegraf_cpu_configs_path, class: "view-all-link"
                end
              else
                para "No remote CPU configs configured", class: "no-data-message"
              end
            end

            tab "Memory Monitoring" do
              configs = MonitoringConfigService.recent_configurations(:memory)

              if configs.any?
                table_for configs do
                  column("Description") { |config| config.description }
                  column("Interval") { |config| config.interval }
                  column("Status") { |config| status_tag(config.active? ? "Active" : "Inactive", class: config.active? ? "status-ok" : "status-error") }
                  column("Actions") do |config|
                    span do
                      [
                        link_to("View", admin_telegraf_memory_config_path(config), class: "table-action"),
                        link_to("Edit", edit_admin_telegraf_memory_config_path(config), class: "table-action")
                      ].join.html_safe
                    end
                  end
                end

                div class: "panel-footer" do
                  link_to "View All Memory Configurations", admin_telegraf_memory_configs_path, class: "view-all-link"
                end
              else
                para "No remote RAM configs configured", class: "no-data-message"
              end
            end

            tab "Docker Monitoring" do
              configs = MonitoringConfigService.recent_configurations(:docker)

              if configs.any?
                table_for configs do
                  column("Description") { |config| config.description }
                  column("Interval") { |config| config.interval }
                  column("Status") { |config| status_tag(config.active? ? "Active" : "Inactive", class: config.active? ? "status-ok" : "status-error") }
                  column("Actions") do |config|
                    span do
                      [
                        link_to("View", admin_telegraf_docker_config_path(config), class: "table-action"),
                        link_to("Edit", edit_admin_telegraf_docker_config_path(config), class: "table-action")
                      ].join.html_safe
                    end
                  end
                end

                div class: "panel-footer" do
                  link_to "View All Docker Configurations", admin_telegraf_docker_configs_path, class: "view-all-link"
                end
              else
                para "No remote Docker configs configured", class: "no-data-message"
              end
            end
          end
        end
      end

      column do
        panel "Remote Hosts Overview", class: "interactive-panel" do
          unique_hosts = HostService.all_monitored_hosts

          if unique_hosts.any?
            div class: "host-stats" do
              # Use MetricsService to collect all host metrics at once
              host_metrics = MetricsService.collect_all_hosts_metrics

              host_metrics.each do |host_data|
                host = host_data[:host]
                metrics = host_data[:metrics]

                div class: "host-card" do
                  h4 host

                  usage_panel(metrics[:cpu_usage], "CPU")
                  usage_panel(metrics[:memory_usage], "Memory")

                  # Display host status
                  div class: "host-status" do
                    status_class = metrics[:status] == "Online" ? "status-ok" : (metrics[:status] == "Error" ? "status-warning" : "status-error")
                    span metrics[:status], class: status_class

                    # Add quick actions for this host
                    # In the host card section, update the ping link:
                    span class: "host-actions" do
                      [
                        link_to("Details", "#", class: "host-action", onclick: "showHostDetails('#{host}'); return false;"),
                        link_to("Ping", admin_dashboard_ping_host_path(remote_host: host), method: :post, remote: true, data: { host: host }, class: "host-action ping-host-btn")
                      ].join.html_safe
                    end
                  end
                end
              end
            end
          else
            para "No remote hosts configured", class: "no-data-message"
          end
        end
      end
    end

    columns do
      column do
        panel "Recent Activity", class: "interactive-panel" do
          div class: "timeline" do
            # In a real app, you'd fetch actual activity data
            sample_activities = [
              { date: 2.hours.ago, content: "CPU monitoring configuration updated" },
              { date: 5.hours.ago, content: "New Docker monitoring added" },
              { date: 1.day.ago, content: "Remote host added to monitoring" },
              { date: 2.days.ago, content: "System restarted" }
            ]

            sample_activities.each do |activity|
              div class: "timeline-item" do
                div(class: "timeline-date") { I18n.l(activity[:date], format: :short) }
                div(class: "timeline-content") { activity[:content] }
              end
            end
          end
        end
      end

      column do
        panel "Quick Actions", class: "interactive-panel" do
          div class: "quick-actions" do
            div class: "action-buttons" do
              [
                link_to("Restart Telegraf", admin_dashboard_restart_telegraf_path, method: :post, data: { confirm: "Are you sure you want to restart Telegraf service?" }, class: "action-button restart-action"),
                link_to("Restart InfluxDB", admin_dashboard_restart_influxdb_path, method: :post, data: { confirm: "Are you sure you want to restart InfluxDB service?" }, class: "action-button restart-action")
              ].join.html_safe
            end
          end
        end
      end
    end

    # Add JavaScript for host details modal and ping functionality
    script do
      raw "
        function showHostDetails(host) {
          $.ajax({
            url: '#{admin_dashboard_host_details_path}',
            data: { host: host },
            dataType: 'script',
            error: function(xhr, status, error) {
              console.error('Error fetching host details:', error);
              alert('Error fetching host details: ' + error);
            }
          });
        }

        function pingHost(host) {
          $.ajax({
            url: '#{admin_dashboard_ping_host_path}',
            method: 'POST',
            data: { host: host },
            dataType: 'script',
            error: function(xhr, status, error) {
              console.error('Error pinging host:', error);
              alert('Error pinging host: ' + error);
            }
          });
        }
      "
    end
  end

  # Remove the duplicate script block and keep only the page actions below

  page_action :ping_host, method: :post do
    host = params[:remote_host]
    result = NetworkService.check_host_availability(host)

    respond_to do |format|
      format.js { render js: "alert('Ping result for host #{host}: #{result}');" }
    end
  end

  page_action :host_details, method: :get do
    @host = params[:remote_host]
    metrics_service = MetricsService.new(@host)
    details = metrics_service.detailed_metrics

    @cpu_data = details[:cpu_data]
    @mem_data = details[:mem_data]
    @disk_data = details[:disk_data]
    @connection_error = details[:error]

    respond_to do |format|
      format.js
    end
  end
end
