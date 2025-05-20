class RemoteHost < ApplicationRecord
  has_many :host_configurations, dependent: :destroy
  has_many :telegraf_cpu_configs, through: :host_configurations, 
           source: :configurable, source_type: 'TelegrafCpuConfig'
  has_many :telegraf_ram_configs, through: :host_configurations, 
           source: :configurable, source_type: 'TelegrafRamConfig'

  validates :hostname, presence: true, uniqueness: true
  validates :username, presence: true
  validates :port, numericality: { only_integer: true, greater_than: 0, less_than: 65536 }

  scope :active, -> { where(active: true) }

  def update_status(new_status)
    update(status: new_status, last_seen_at: Time.current)
  end
end