class CreateAlertRules < ActiveRecord::Migration[7.0]
  def change
    create_table :alert_rules do |t|
      t.string :name, null: false
      t.string :metric_type, null: false
      t.string :operator, null: false
      t.float :threshold, null: false
      t.string :severity, null: false
      t.string :duration, null: false
      t.text :description
      t.boolean :active, default: true

      t.timestamps
    end
    
    add_index :alert_rules, :name
    add_index :alert_rules, :metric_type
  end
end