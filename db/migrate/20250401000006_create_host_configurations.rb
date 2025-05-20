class CreateHostConfigurations < ActiveRecord::Migration[7.0]
  def change
    create_table :host_configurations do |t|
      t.references :remote_host, null: false, foreign_key: true
      t.references :configurable, polymorphic: true, null: false
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :host_configurations, [:remote_host_id, :configurable_type, :configurable_id], 
              unique: true, 
              name: 'index_host_configurations_uniqueness'
  end
end