class DropTelegrafDockerConfigs < ActiveRecord::Migration[7.0]
  def up
    drop_table :telegraf_docker_configs
  end

  def down
    create_table :telegraf_docker_configs do |t|
      t.string :description
      t.string :interval, null: false
      t.boolean :gather_services, default: false
      t.text :container_names
      t.text :container_name_include
      t.text :container_name_exclude
      t.boolean :active, default: true

      t.timestamps
    end
  end
end