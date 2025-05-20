class CreateRemoteHosts < ActiveRecord::Migration[7.0]
  def change
    create_table :remote_hosts do |t|
      t.string :hostname, null: false
      t.integer :port, null: false, default: 22
      t.string :description
      t.string :username, null: false
      t.boolean :active, default: true
      t.string :status
      t.datetime :last_seen_at

      t.timestamps
    end

    add_index :remote_hosts, :hostname, unique: true
  end
end