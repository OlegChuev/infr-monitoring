class SystemService
  class << self
    def restart_service(service_name)
      begin
        # Use docker-compose for containerized services
        if in_docker_environment?
          result = system("docker-compose restart #{service_name}")
        else
          result = system("sudo systemctl restart #{service_name}")
        end

        if result
          { success: true, message: "#{service_name.capitalize} service restarted successfully" }
        else
          { success: false, message: "Failed to restart #{service_name.capitalize} service" }
        end
      rescue => e
        { success: false, message: "Error restarting #{service_name.capitalize}: #{e.message}" }
      end
    end

    def check_service_status(service_name)
      if in_docker_environment?
        container_running?(service_name) ? "Running" : "Stopped"
      else
        system("pgrep #{service_name} > /dev/null") ? "Running" : "Stopped"
      end
    end

    def system_status
      telegraf_status = check_service_status("telegraf")
      influxdb_status = check_service_status("influxd")

      {
        telegraf: telegraf_status,
        influxdb: influxdb_status,
        healthy: (telegraf_status == "Running" && influxdb_status == "Running")
      }
    end

    def in_docker_environment?
      # Check if running in Docker environment
      File.exist?("/.dockerenv") || system("grep -q docker /proc/1/cgroup 2>/dev/null")
    end

    def container_running?(container_name)
      system("docker ps --format '{{.Names}}' | grep -q #{container_name}")
    end

    def docker_compose_services
      `docker-compose ps --services`.split("\n")
    end

    def docker_containers_status
      containers = `docker ps --format '{{.Names}},{{.Status}},{{.Image}}'`.split("\n")
      containers.map do |container|
        name, status, image = container.split(",")
        {
          name: name,
          status: status,
          image: image,
          running: status.include?("Up")
        }
      end
    end
  end
end
