class CreateTelegrafCpuConfigs < ActiveRecord::Migration[7.0]
  def change
    create_table :telegraf_cpu_configs do |t|
      t.string :name, null: false
      t.string :interval, null: false
      t.text :description
      t.boolean :active, default: true
      t.references :alert_rule, foreign_key: true

      t.timestamps
    end
    
    add_index :telegraf_cpu_configs, :name, unique: true
  end
end