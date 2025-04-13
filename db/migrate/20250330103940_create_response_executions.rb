class CreateResponseExecutions < ActiveRecord::Migration[7.0]
  def change
    create_table :response_executions do |t|
      t.references :automated_response, null: false, foreign_key: true
      t.string :status
      t.text :result
      t.datetime :executed_at

      t.timestamps
    end
    
    add_index :response_executions, :executed_at
  end
end