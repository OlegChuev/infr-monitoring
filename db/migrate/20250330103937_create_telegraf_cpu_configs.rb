class CreateTelegrafCpuConfigs < ActiveRecord::Migration[7.2]
  def change
    create_table :telegraf_cpu_configs do |t|
      t.string :description
      t.string :interval, default: "10s"
      t.boolean :active, default: true

      # CPU specific settings
      t.boolean :percpu, default: true
      t.boolean :totalcpu, default: true
      t.boolean :collect_cpu_time, default: false
      t.boolean :report_active, default: false

      # Remote host monitoring
      t.text :remote_hosts
      t.boolean :use_ssh
      t.string :ssh_user

      t.timestamps
    end

    create_table :telegraf_memory_configs do |t|
      t.string :description
      t.string :interval, default: "10s"
      t.boolean :active, default: true

      # Memory specific settings
      t.boolean :swap_memory, default: true
      t.boolean :platform_memory, default: true

      # Remote host monitoring
      t.text :remote_hosts
      t.boolean :use_ssh
      t.string :ssh_user

      t.timestamps
    end

    # Docker config remains the same
    create_table :telegraf_docker_configs do |t|
      t.string :description
      t.string :interval, default: "10s"
      t.boolean :active, default: true
      t.text :container_name_include
      t.text :container_name_exclude
      t.boolean :perdevice, default: true
      t.boolean :total, default: true
      t.string :timeout, default: "5s"
      t.boolean :gather_services, default: false

      t.text :remote_hosts
      t.boolean :use_ssh
      t.string :ssh_user

      t.timestamps
    end
  end
end
