class CreateAutomatedResponses < ActiveRecord::Migration[7.0]
  def change
    create_table :automated_responses do |t|
      t.references :alert_rule, null: false, foreign_key: true
      t.string :action_type, null: false
      t.string :target_service, null: false
      t.string :cooldown_period, null: false
      t.text :description
      t.boolean :active, default: true

      t.timestamps
    end
  end
end